// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimeCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "TimeCore",
            targets: ["TimeCore"]
        ),
    ],
    targets: [
        .target(
            name: "TimeCore",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .testTarget(
            name: "TimeCoreTests",
            dependencies: ["TimeCore"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
