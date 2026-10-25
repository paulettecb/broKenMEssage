import XCTest
@testable import VozCore

final class ReversaTests: XCTestCase {
    func testInvierteCadaCanal() {
        XCTAssertEqual(Reversa.invertir([[1, 2, 3], [4, 5, 6]]), [[3, 2, 1], [6, 5, 4]])
    }

    func testInvertirDosVecesRegresaAlOriginal() {
        let original: [[Float]] = [[0.1, -0.5, 0.3, 0.9]]
        XCTAssertEqual(Reversa.invertir(Reversa.invertir(original)), original)
    }

    func testTramoConSonidoIgnoraSilencioDeLasOrillas() {
        let muestras: [Float] = [0, 0.001, 0.5, -0.4, 0.3, 0.0, 0]
        XCTAssertEqual(Reversa.tramoConSonido(muestras), 2..<5)
        XCTAssertEqual(Reversa.tramoConSonido(muestras, margen: 1), 1..<6)
        XCTAssertEqual(Reversa.tramoConSonido(muestras, margen: 10), 0..<7)
    }

    func testTodoSilencio() {
        XCTAssertNil(Reversa.tramoConSonido([0, 0.001, -0.001]))
        XCTAssertEqual(Reversa.recortarEInvertir([[0, 0.001]]), [[0.001, 0]])
    }

    func testRecortaTodosLosCanalesIgual() {
        let canales: [[Float]] = [[0, 0.5, 0.6, 0], [9, 1, 2, 9]]
        XCTAssertEqual(Reversa.recortarEInvertir(canales), [[0.6, 0.5], [2, 1]])
    }

    func testNormalizarSubeHastaElPico() {
        let r = Reversa.normalizar([[0.1, -0.3, 0.2]])
        XCTAssertEqual(r[0][1], -0.9, accuracy: 0.0001)
        XCTAssertEqual(r[0][0], 0.3, accuracy: 0.0001)
    }

    func testNormalizarNoExageraElRuido() {
        // Pico de 0.01: llegar a 0.9 serían ×90; se queda en ×12.
        XCTAssertEqual(Reversa.normalizar([[0.01]])[0][0], 0.12, accuracy: 0.0001)
    }

    func testNormalizarSilencioNoHaceNada() {
        XCTAssertEqual(Reversa.normalizar([[0, 0]]), [[0, 0]])
    }
}
