// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "IRIXIDE",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "IRIXDesignSystem",
            targets: ["IRIXDesignSystem"]
        ),
        .library(
            name: "IRIXServices",
            targets: ["IRIXServices"]
        ),
        .library(
            name: "IRIXFeatures",
            targets: ["IRIXFeatures"]
        ),
        .executable(
            name: "IRIXIDEApp",
            targets: ["IRIXIDEApp"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.0")
    ],
    targets: [
        .target(
            name: "IRIXDesignSystem"
        ),
        .target(
            name: "IRIXServices",
            dependencies: [
                .product(name: "Yams", package: "Yams")
            ]
        ),
        .target(
            name: "IRIXFeatures",
            dependencies: [
                "IRIXDesignSystem",
                "IRIXServices"
            ]
        ),
        .executableTarget(
            name: "IRIXIDEApp",
            dependencies: [
                "IRIXFeatures",
                "IRIXDesignSystem",
                "IRIXServices"
            ]
        ),
        .testTarget(
            name: "IRIXIDETests",
            dependencies: ["IRIXServices"]
        )
    ]
)
