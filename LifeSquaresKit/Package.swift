// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LifeSquaresKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "LifeSquaresKit",
            targets: ["LifeSquaresKit"]
        ),
    ],
    dependencies: [
        .package(path: "../TimeCore")
    ],
    targets: [
        .target(
            name: "LifeSquaresKit",
            dependencies: [.product(name: "TimeCore", package: "TimeCore")],
            resources: [.process("Resources")],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .testTarget(
            name: "LifeSquaresKitTests",
            dependencies: ["LifeSquaresKit"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
