# broKenMEssage ✦


Una persona dice algo (Britney Spears, aguacate, tu ex). El teléfono lo voltea al revés. La otra persona lo imita tal cual, al revés. El teléfono voltea la imitación al derecho y… ¿se entiende? Como teléfono descompuesto, pero con audio.

Hecho para jugar en el coche con quien va de copiloto: el sonido sale por las bocinas del coche y se graba con el micrófono del teléfono. Estilo: design system de dopaminique_.

> Mockup: artifact "Juego de voz al revés · mockup" (privado, en claude.ai).

## ▶️ Abrirla en Xcode
```bash
brew install xcodegen          # solo la primera vez
git clone https://github.com/paulettecb/broKenMEssage.git && cd broKenMEssage
xcodegen
open BrokenMessage.xcodeproj
```
Tu Team ya está en `project.yml`. Conecta el iPhone y ▶︎.

## Cómo funciona
| Pieza | Archivo |
|---|---|
| Los 4 pasos y el marcador | `App/Juego.swift` |
| Grabar, voltear y reproducir | `App/MotorDeVoz.swift` |
| Las pantallas (carmín, vino, oro, orquídea) | `App/PantallaJuego.swift` |
| Voltear y quitar silencios (Swift puro, con pruebas) | `VozCore/` → `cd VozCore && swift test` |
| Estilo | `Shared/Dopaminique.swift`, `Shared/Fonts/` |

Nada sale del teléfono: las grabaciones viven en una carpeta temporal y se reemplazan cada ronda.

## Pendientes
- [x] Nombre: broKenMEssage
- [ ] Ícono
- [ ] Primer build en Xcode
- [ ] Botón en el Centro de control / botón de acción para abrir directo en "Grabar"
