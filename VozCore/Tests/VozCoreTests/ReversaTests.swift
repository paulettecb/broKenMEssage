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
}
