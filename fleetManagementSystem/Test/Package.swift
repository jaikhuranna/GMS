// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "FleetSystemTests",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FleetSystemTests",
            targets: ["FleetSystemTests"]),
    ],
    dependencies: [],
    targets: [
        .testTarget(
            name: "FleetSystemTests",
            dependencies: [],
            path: "Tests"
        )
    ]
) 