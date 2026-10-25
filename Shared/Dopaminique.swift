import SwiftUI

/// Tokens del design system dopaminique_ (fuente: artifact "dopaminique_ Design System").
enum Paleta {
    static let hueso = Color(hex: 0xFBFAF7)
    static let hueso2 = Color(hex: 0xF4F2ED)
    static let hueso3 = Color(hex: 0xEAE7E0)
    static let tinta = Color(hex: 0x2A2430)
    static let tinta70 = Color(hex: 0x2A2430).opacity(0.7)
    static let carmin = Color(hex: 0xC41230)
    static let vino = Color(hex: 0x3A0A24)
    static let vinoSuave = Color(hex: 0xA8456B)
    static let fucsia = Color(hex: 0xF0158C)
    static let fucsiaProfunda = Color(hex: 0xA80F68)
    static let oro = Color(hex: 0xE8A400)
    static let oroProfundo = Color(hex: 0x8C5F00)
    static let orquidea = Color(hex: 0xECC9EA)
    static let orquideaProfunda = Color(hex: 0x8A4B87)
}

/// Familias: Lumiare (títulos), Bricolage (texto), Friendship (etiquetas, siempre MAYÚSCULAS),
/// Mallcity (firma, máximo dos por pieza). Nombres PostScript de los archivos en Shared/Fonts.
enum Tipo {
    static func titulo(_ size: CGFloat) -> Font { .custom("Lumiare-Regular", size: size) }
    static func texto(_ size: CGFloat) -> Font { .custom("BricolageGrotesque-Regular", size: size) }
    static func textoFuerte(_ size: CGFloat) -> Font { .custom("BricolageGrotesque-SemiBold", size: size) }
    static func etiqueta(_ size: CGFloat) -> Font { .custom("Friendship-Medium", size: size) }
    static func firma(_ size: CGFloat) -> Font { .custom("Mallcity", size: size) }
}

/// Eyebrow en Friendship: mayúsculas con espaciado .14em.
struct Etiqueta: View {
    let texto: String
    var color: Color = Paleta.fucsiaProfunda
    var size: CGFloat = 13

    var body: some View {
        Text(texto.uppercased())
            .font(Tipo.etiqueta(size))
            .tracking(size * 0.14)
            .foregroundStyle(color)
    }
}

/// El destello de cuatro puntas: puntuación en línea, nunca relleno.
struct Destello: Shape {
    func path(in r: CGRect) -> Path {
        let c = CGPoint(x: r.midX, y: r.midY), w = r.width / 2, h = r.height / 2, k: CGFloat = 0.22
        var p = Path()
        p.move(to: CGPoint(x: c.x, y: c.y - h))
        p.addLine(to: CGPoint(x: c.x + w * k, y: c.y - h * k))
        p.addLine(to: CGPoint(x: c.x + w, y: c.y))
        p.addLine(to: CGPoint(x: c.x + w * k, y: c.y + h * k))
        p.addLine(to: CGPoint(x: c.x, y: c.y + h))
        p.addLine(to: CGPoint(x: c.x - w * k, y: c.y + h * k))
        p.addLine(to: CGPoint(x: c.x - w, y: c.y))
        p.addLine(to: CGPoint(x: c.x - w * k, y: c.y - h * k))
        p.closeSubpath()
        return p
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}
