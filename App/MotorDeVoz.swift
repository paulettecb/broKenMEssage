import AVFoundation
import VozCore

/// Graba, voltea y reproduce. Todo pasa en el iPhone, sin internet.
///
/// El sonido sale por donde esté conectado el iPhone (bocinas del coche por Bluetooth o
/// CarPlay), pero se graba con el micrófono del teléfono: así quien juega habla al
/// teléfono que tiene en la mano.
@MainActor
final class MotorDeVoz: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published private(set) var grabando = false
    @Published private(set) var reproduciendo = false
    @Published private(set) var inicioGrabacion: Date?

    private var grabadora: AVAudioRecorder?
    private var reproductor: AVAudioPlayer?
    private var alTerminar: (() -> Void)?

    func pedirPermiso() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    /// Grabar y reproducir usan modos distintos a propósito: con el modo de grabar
    /// (`.playAndRecord`) iOS baja bastante el volumen de la bocina. Por eso solo se usa
    /// mientras se graba, y para escuchar se cambia a `.playback`, que suena a todo volumen.
    private func prepararSesion(grabar: Bool) throws {
        let sesion = AVAudioSession.sharedInstance()
        if grabar {
            // Sin `.allowBluetooth` a propósito: con él, iOS cambia al micrófono del coche en modo
            // "llamada" y el sonido se oye feo. Así graba el micrófono del teléfono.
            try sesion.setCategory(.playAndRecord, mode: .default,
                                   options: [.defaultToSpeaker, .allowBluetoothA2DP, .allowAirPlay])
        } else {
            try sesion.setCategory(.playback, mode: .default)
        }
        try sesion.setActive(true)
    }

    // MARK: - Grabar

    func empezarAGrabar(como nombre: String) throws {
        detener()
        try prepararSesion(grabar: true)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(nombre).caf")
        try? FileManager.default.removeItem(at: url)
        let ajustes: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsFloatKey: true
        ]
        grabadora = try AVAudioRecorder(url: url, settings: ajustes)
        grabadora?.record()
        grabando = true
        inicioGrabacion = Date()
    }

    /// Detiene la grabación y regresa el archivo grabado.
    func terminarDeGrabar() -> URL? {
        guard let grabadora else { return nil }
        grabadora.stop()
        self.grabadora = nil
        grabando = false
        inicioGrabacion = nil
        return grabadora.url
    }

    // MARK: - Voltear

    /// Lee el archivo, le quita el silencio de las orillas y lo escribe al revés en otro archivo.
    func voltear(_ url: URL, como nombre: String) throws -> URL {
        let entrada = try AVAudioFile(forReading: url)
        let formato = entrada.processingFormat
        let cuadros = AVAudioFrameCount(entrada.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: formato, frameCapacity: cuadros) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        try entrada.read(into: buffer)
        guard let datos = buffer.floatChannelData else { throw CocoaError(.fileReadCorruptFile) }

        let canales = (0..<Int(formato.channelCount)).map { c in
            Array(UnsafeBufferPointer(start: datos[c], count: Int(buffer.frameLength)))
        }
        // 0.08 s de aire para que no empiece de golpe.
        // Además se sube el volumen de la grabación: la voz a medio metro del teléfono queda bajita.
        let volteados = Reversa.normalizar(Reversa.recortarEInvertir(canales, margen: Int(formato.sampleRate * 0.08)))

        let largo = AVAudioFrameCount(volteados.first?.count ?? 0)
        guard let salidaBuffer = AVAudioPCMBuffer(pcmFormat: formato, frameCapacity: max(largo, 1)),
              let salidaDatos = salidaBuffer.floatChannelData else { throw CocoaError(.fileWriteUnknown) }
        salidaBuffer.frameLength = largo
        for (c, muestras) in volteados.enumerated() where !muestras.isEmpty {
            muestras.withUnsafeBufferPointer { salidaDatos[c].update(from: $0.baseAddress!, count: muestras.count) }
        }

        let destino = FileManager.default.temporaryDirectory.appendingPathComponent("\(nombre).caf")
        try? FileManager.default.removeItem(at: destino)
        let salida = try AVAudioFile(forWriting: destino, settings: formato.settings,
                                     commonFormat: .pcmFormatFloat32, interleaved: false)
        try salida.write(from: salidaBuffer)
        return destino
    }

    // MARK: - Reproducir

    func reproducir(_ url: URL, alTerminar: (() -> Void)? = nil) {
        detener()
        do {
            try prepararSesion(grabar: false)
            reproductor = try AVAudioPlayer(contentsOf: url)
            reproductor?.delegate = self
            reproductor?.volume = 1
            self.alTerminar = alTerminar
            reproductor?.play()
            reproduciendo = true
        } catch {
            print("No pude reproducir: \(error)")
        }
    }

    func detener() {
        reproductor?.stop()
        reproductor = nil
        reproduciendo = false
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.reproduciendo = false
            let accion = self.alTerminar
            self.alTerminar = nil
            accion?()
        }
    }
}
