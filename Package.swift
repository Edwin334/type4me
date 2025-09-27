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
            name: "TypeForMe",
            targets: ["TypeForMe"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/google/generative-ai-swift", from: "0.5.4")
    ],
    targets: [
        .target(
            name: "TypeForMeCore",
            dependencies: []
        ),
        .executableTarget(
            name: "TypeForMe",
            dependencies: [
                "TypeForMeCore",
                .product(name: "GoogleGenerativeAI", package: "generative-ai-swift")
            ]
        ),
        .testTarget(
            name: "TypeForMeCoreTests",
            dependencies: ["TypeForMeCore", "TypeForMe"]
        )
    ]
)
