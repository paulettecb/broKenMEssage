import SwiftUI

@main
struct BrokenMessageApp: App {
    @StateObject private var juego = Juego()

    var body: some Scene {
        WindowGroup {
            PantallaJuego()
                .environmentObject(juego)
                .environmentObject(juego.voz)
        }
    }
}
