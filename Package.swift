// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TypeForMe",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "TypeForMeCore",
            targets: ["TypeForMeCore"]
        ),
        .executable(
            name: "TypeForMeCLI",
            targets: ["TypeForMeCLI"]
        )
    ],
    targets: [
        .target(
            name: "TypeForMeCore",
            dependencies: [],
            resources: [.copy("Resources")]
        ),
        .executableTarget(
            name: "TypeForMeCLI",
            dependencies: ["TypeForMeCore"]
        ),
        .testTarget(
            name: "TypeForMeCoreTests",
            dependencies: ["TypeForMeCore"],
            resources: [.copy("Fixtures")]
        )
    ]
)
