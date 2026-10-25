import SwiftUI

/// Las cuatro pantallas del mockup, cada paso con su color de dopaminique_:
/// carmín (inventa), vino (al revés), oro (adivina), orquídea (la prueba).
struct PantallaJuego: View {
    @EnvironmentObject private var juego: Juego
    @EnvironmentObject private var voz: MotorDeVoz

    private var colores: (fondo: Color, texto: Color, acento: Color) {
        switch juego.paso {
        case .inventa: return (Paleta.carmin, Paleta.hueso, Paleta.oro)
        case .alReves: return (Paleta.vino, Paleta.hueso, Paleta.oro)
        case .adivina: return (Paleta.oro, Paleta.tinta, Paleta.vino)
        case .prueba: return (Paleta.orquidea, Paleta.tinta, Paleta.fucsiaProfunda)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            barraSuperior
            encabezado
            Spacer(minLength: 0)
            contenido
            Spacer(minLength: 0)
            if let error = juego.error {
                Text(error).font(Tipo.textoFuerte(15)).frame(maxWidth: .infinity)
            }
            puntos
        }
        .padding(.horizontal, 26)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .foregroundStyle(colores.texto)
        .background(colores.fondo.ignoresSafeArea())
        .animation(.easeOut(duration: 0.2), value: juego.paso)
        .task { await juego.arrancar() }
    }

    // MARK: - Arriba

    private var barraSuperior: some View {
        HStack {
            Etiqueta(texto: String(format: "Ronda %02d", juego.ronda), color: colores.texto, size: 14)
            Spacer()
            Menu {
                Button("Empezar de cero", role: .destructive) { juego.reiniciar() }
            } label: {
                Etiqueta(texto: "Aciertos \(juego.aciertos)", color: colores.texto, size: 14)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(colores.texto.opacity(0.14), in: Capsule())
            }
        }
    }

    /// Una sola palabra por paso, como el mockup simplificado: nada de instrucciones largas.
    private var encabezado: some View {
        let titulo: String = {
            switch juego.paso {
            case .inventa: return "Empezar"
            case .alReves: return "Escucha"
            case .adivina: return "Repite"
            case .prueba: return "¿Le atinaste?"
            }
        }()
        return Text(titulo)
            .font(Tipo.titulo(52))
            .padding(.top, 16)
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - En medio

    @ViewBuilder private var contenido: some View {
        if juego.sinPermiso {
            Text("Para jugar, dale permiso al micrófono en Ajustes → este juego → Micrófono.")
                .font(Tipo.textoFuerte(17))
                .frame(maxWidth: .infinity)
        } else {
            switch juego.paso {
            case .inventa: botonGrabar(fondo: Paleta.vino, texto: Paleta.hueso)
            case .alReves: pasoAlReves
            case .adivina: botonGrabar(fondo: Paleta.vino, texto: Paleta.hueso)
            case .prueba: pasoPrueba
            }
        }
    }

    private func botonGrabar(fondo: Color, texto: Color) -> some View {
        VStack(spacing: 16) {
            if let inicio = voz.inicioGrabacion {
                Text(timerInterval: inicio...Date.distantFuture, countsDown: false)
                    .font(Tipo.etiqueta(30))
                    .monospacedDigit()
            }
            Button(action: juego.tocarGrabar) {
                VStack(spacing: 12) {
                    Image(systemName: voz.grabando ? "stop.fill" : "mic")
                        .font(.system(size: 44, weight: .medium))
                    Text(voz.grabando ? "DETENER" : "GRABAR")
                        .font(Tipo.etiqueta(22))
                        .tracking(22 * 0.12)
                }
                .foregroundStyle(texto)
                .frame(width: 220, height: 220)
                // La sombra va SOLO en el círculo: puesta en todo el botón, también le hacía
                // sombra a las letras y se veían dobles.
                .background(Circle().fill(fondo).shadow(color: Paleta.tinta, radius: 0, x: 0, y: 4))
                .overlay(Circle().stroke(Paleta.hueso, lineWidth: voz.grabando ? 8 : 0))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(voz.grabando ? "Detener grabación" : "Grabar")
            if juego.paso == .adivina && !voz.grabando {
                botonContorno("Oírla al revés otra vez", accion: juego.escucharAlReves)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var pasoAlReves: some View {
        VStack(spacing: 22) {
            Ondas(sonando: voz.reproduciendo, color: Paleta.orquidea, acento: Paleta.oro)
            Button(action: juego.escucharAlReves) {
                VStack(spacing: 10) {
                    Image(systemName: voz.reproduciendo ? "speaker.wave.3.fill" : "arrow.counterclockwise")
                        .font(.system(size: 40, weight: .medium))
                    Text(voz.reproduciendo ? "SONANDO…" : "OTRA VEZ")
                        .font(Tipo.etiqueta(18))
                        .tracking(18 * 0.12)
                }
                .foregroundStyle(Paleta.tinta)
                .frame(width: 180, height: 180)
                .background(Circle().fill(Paleta.oro).shadow(color: Paleta.tinta, radius: 0, x: 0, y: 4))
            }
            .buttonStyle(.plain)
            botonContorno("Ya, pásale el teléfono →", accion: juego.pasarTelefono)
        }
        .frame(maxWidth: .infinity)
    }

    private var pasoPrueba: some View {
        VStack(spacing: 14) {
            Button(action: juego.escucharImitacion) {
                HStack(spacing: 14) {
                    Image(systemName: "play.fill").font(.system(size: 30))
                    Text("ESCUCHAR MI VERSIÓN").font(Tipo.etiqueta(20)).tracking(20 * 0.12)
                }
                .foregroundStyle(Paleta.hueso)
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(RoundedRectangle(cornerRadius: 28).fill(Paleta.carmin)
                    .shadow(color: Paleta.tinta, radius: 0, x: 0, y: 4))
            }
            .buttonStyle(.plain)

            Button(action: juego.revelarOriginal) {
                Text(juego.originalRevelada ? "OÍR LA ORIGINAL OTRA VEZ" : "REVELAR LA ORIGINAL")
                    .font(Tipo.etiqueta(16)).tracking(16 * 0.12)
                    .foregroundStyle(Paleta.vino)
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(Paleta.hueso, in: Capsule())
                    .overlay(Capsule().stroke(Paleta.vino, lineWidth: 2))
            }
            .buttonStyle(.plain)

            if juego.originalRevelada {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Button { juego.veredicto(leAtino: true) } label: {
                            Text("SÍ, PUNTO").font(Tipo.etiqueta(15)).tracking(15 * 0.12)
                                .foregroundStyle(Paleta.hueso)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(Paleta.vino, in: Capsule())
                        }
                        Button { juego.veredicto(leAtino: false) } label: {
                            Text("NI CERCA").font(Tipo.etiqueta(15)).tracking(15 * 0.12)
                                .foregroundStyle(Paleta.vino)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .overlay(Capsule().stroke(Paleta.vino, lineWidth: 2))
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 14)
            }
        }
    }

    private func botonContorno(_ texto: String, accion: @escaping () -> Void) -> some View {
        Button(action: accion) {
            Text(texto.uppercased())
                .font(Tipo.etiqueta(15)).tracking(15 * 0.12)
                .frame(maxWidth: .infinity, minHeight: 56)
                .overlay(Capsule().stroke(colores.texto, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .foregroundStyle(colores.texto)
    }

    // MARK: - Abajo

    private var puntos: some View {
        HStack(spacing: 6) {
            ForEach(1...4, id: \.self) { n in
                Capsule()
                    .fill(n == juego.paso.rawValue ? colores.texto : colores.texto.opacity(0.3))
                    .frame(width: n == juego.paso.rawValue ? 34 : 8, height: 8)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Paso \(juego.paso.rawValue) de 4")
    }
}

/// Las rayitas del mockup: se mueven mientras suena el audio y se quedan quietas si no.
struct Ondas: View {
    let sonando: Bool
    let color: Color
    let acento: Color
    private let base: [CGFloat] = [18, 34, 56, 30, 70, 82, 48, 64, 26, 52, 76, 40, 22, 12]

    var body: some View {
        TimelineView(.animation(paused: !sonando)) { contexto in
            let t = contexto.date.timeIntervalSinceReferenceDate
            HStack(spacing: 5) {
                ForEach(base.indices, id: \.self) { i in
                    let vaiven = sonando ? 0.55 + 0.45 * abs(sin(t * 6 + Double(i) * 0.7)) : 1
                    Capsule()
                        .fill(i < 5 ? color : acento)
                        .frame(width: 7, height: max(10, base[i] * vaiven))
                }
            }
            .frame(height: 86)
        }
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }
}
