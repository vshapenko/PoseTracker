// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PoseTracker",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "PoseTracker",
            targets: ["PoseTracker"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PoseTracker",
            dependencies: []),
    ]
)