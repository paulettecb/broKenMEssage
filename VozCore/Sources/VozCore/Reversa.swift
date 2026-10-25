/// La mate del juego, sin nada de audio de iOS: voltear muestras y quitar silencios.
///
/// Quitar el silencio de las orillas importa mucho: el silencio del final de una grabación,
/// al voltearla, se vuelve silencio al principio, y quien adivina se pierde esperando.
public enum Reversa {
    /// Cada canal al revés.
    public static func invertir(_ canales: [[Float]]) -> [[Float]] {
        canales.map { Array($0.reversed()) }
    }

    /// El tramo con sonido: desde la primera muestra que pasa `umbral` hasta la última,
    /// dejando `margen` muestras de aire a cada lado. `nil` si todo es silencio.
    public static func tramoConSonido(_ muestras: [Float], umbral: Float = 0.02, margen: Int = 0) -> Range<Int>? {
        guard let primera = muestras.firstIndex(where: { abs($0) > umbral }),
              let ultima = muestras.lastIndex(where: { abs($0) > umbral }) else { return nil }
        return max(0, primera - margen)..<min(muestras.count, ultima + 1 + margen)
    }

    /// Recorta todos los canales al tramo con sonido del primero y los voltea.
    /// Si todo es silencio, los regresa volteados sin recortar.
    public static func recortarEInvertir(_ canales: [[Float]], umbral: Float = 0.02, margen: Int = 0) -> [[Float]] {
        guard let base = canales.first, let tramo = tramoConSonido(base, umbral: umbral, margen: margen) else {
            return invertir(canales)
        }
        return invertir(canales.map { Array($0[tramo]) })
    }

    /// Sube (o baja) el volumen para que el pico más alto llegue a `pico`, sin pasarse de
    /// `gananciaMaxima` para no convertir el ruido de fondo de una grabación muda en un rugido.
    public static func normalizar(_ canales: [[Float]], pico: Float = 0.9, gananciaMaxima: Float = 12) -> [[Float]] {
        let maximo = canales.flatMap { $0 }.map(abs).max() ?? 0
        guard maximo > 0 else { return canales }
        let ganancia = min(pico / maximo, gananciaMaxima)
        return canales.map { $0.map { $0 * ganancia } }
    }
}
