import Foundation

/// Una ronda, un botón. Los cuatro pasos del mockup:
/// 1. Quien inventa graba → 2. todos lo oyen al revés → 3. quien adivina lo imita →
/// 4. la imitación se voltea al derecho y se compara con la original.
@MainActor
final class Juego: ObservableObject {
    enum Paso: Int { case inventa = 1, alReves, adivina, prueba }

    @Published private(set) var paso: Paso = .inventa
    @Published private(set) var ronda = 1
    @Published private(set) var aciertos = 0
    @Published private(set) var error: String?
    @Published private(set) var sinPermiso = false
    @Published private(set) var originalRevelada = false

    let voz = MotorDeVoz()

    private var original: URL?
    private var originalAlReves: URL?
    private var imitacionAlDerecho: URL?

    func arrancar() async {
        sinPermiso = !(await voz.pedirPermiso())
    }

    /// El botón gigante de los pasos 1 y 3: graba o detiene.
    func tocarGrabar() {
        error = nil
        if voz.grabando { terminarGrabacion() } else { empezarGrabacion() }
    }

    private func empezarGrabacion() {
        do {
            try voz.empezarAGrabar(como: paso == .inventa ? "original" : "imitacion")
        } catch {
            self.error = "No pude grabar. ¿Le diste permiso al micrófono?"
        }
    }

    private func terminarGrabacion() {
        guard let grabado = voz.terminarDeGrabar() else { return }
        do {
            switch paso {
            case .inventa:
                let alReves = try voz.voltear(grabado, como: "original-al-reves")
                originalAlReves = alReves
                // Volteada dos veces = la original, pero ya recortada y con el volumen arriba.
                original = try voz.voltear(alReves, como: "original-limpia")
                paso = .alReves
                escucharAlReves()
            case .adivina:
                imitacionAlDerecho = try voz.voltear(grabado, como: "imitacion-al-derecho")
                originalRevelada = false
                paso = .prueba
                escucharImitacion()
            default:
                break
            }
        } catch {
            self.error = "No pude voltear el audio. Intenten grabar otra vez."
        }
    }

    func escucharAlReves() {
        if let originalAlReves { voz.reproducir(originalAlReves) }
    }

    func pasarTelefono() {
        voz.detener()
        paso = .adivina
    }

    func escucharImitacion() {
        if let imitacionAlDerecho { voz.reproducir(imitacionAlDerecho) }
    }

    func revelarOriginal() {
        guard let original else { return }
        originalRevelada = true
        voz.reproducir(original)
    }

    func veredicto(leAtino: Bool) {
        if leAtino { aciertos += 1 }
        voz.detener()
        original = nil
        originalAlReves = nil
        imitacionAlDerecho = nil
        originalRevelada = false
        ronda += 1
        paso = .inventa
    }

    func reiniciar() {
        veredicto(leAtino: false)
        ronda = 1
        aciertos = 0
    }
}
