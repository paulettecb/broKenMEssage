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

    private var encabezado: some View {
        let textos: (String, String, String) = {
            switch juego.paso {
            case .inventa:
                return ("Paso 1 de 4 · Quien inventa", "Di un nombre, una palabra, lo que sea",
                        "Que nadie más vea qué es. Britney Spears, aguacate, tu ex.")
            case .alReves:
                return ("Paso 2 de 4 · Así suena al revés", "Escúchala volteada",
                        "Todos la oyen. Quien adivina, a memorizar cómo suena.")
            case .adivina:
                return ("Paso 3 de 4 · Quien adivina", "Repite lo que oíste, tal cual",
                        "Al revés también, aunque suene a idioma inventado. Entre más parecido, mejor sale al voltearlo.")
            case .prueba:
                return ("Paso 4 de 4 · La prueba", "Tu versión, volteada al derecho",
                        "Escúchenla y adivinen qué dijo. Luego, la original.")
            }
        }()
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Destello().fill(colores.acento).frame(width: 13, height: 13)
                Etiqueta(texto: textos.0, color: colores.texto, size: 13)
            }
            Text(textos.1)
                .font(Tipo.titulo(44))
                .lineSpacing(-4)
                .fixedSize(horizontal: false, vertical: true)
            Text(textos.2)
                .font(Tipo.texto(17))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 12)
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
            Text(voz.grabando ? "Grabando… toca para parar." : "Toca para empezar, toca otra vez para parar.")
                .font(Tipo.texto(15))
                .multilineTextAlignment(.center)
            if juego.paso == .adivina && !voz.grabando {
                botonContorno("Oírla al revés otra vez", accion: juego.escucharAlReves)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var pasoAlReves: some View {
        VStack(spacing: 22) {
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
                    Text("¿le atinó?").font(Tipo.firma(26)).foregroundStyle(Paleta.vino)
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
