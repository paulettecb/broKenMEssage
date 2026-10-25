// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "VozCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "VozCore", targets: ["VozCore"])],
    targets: [
        .target(name: "VozCore"),
        .testTarget(name: "VozCoreTests", dependencies: ["VozCore"])
    ]
)
