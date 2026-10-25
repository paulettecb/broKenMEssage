import SwiftUI

@main
struct JuegoDeVozApp: App {
    @StateObject private var juego = Juego()

    var body: some Scene {
        WindowGroup {
            PantallaJuego()
                .environmentObject(juego)
                .environmentObject(juego.voz)
        }
    }
}
