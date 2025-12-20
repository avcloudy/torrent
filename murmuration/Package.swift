// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "murmuration", platforms: [.macOS(.v26)],
    products: [
        .library(name: "torrent", targets: ["torrent"]),
        .library(name: "core", targets: ["core"]),
        .library(name: "cli", targets: ["cli"]),
        .executable(name: "murmuration", targets: ["murmuration"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.7.0")
    ],
    targets: [
        .target(
            name: "torrent",
            resources: [
                .copy("Resources")
            ]),
        .target(
            name: "core", dependencies: ["torrent"],
        ),
        .target(
            name: "cli", dependencies: [
                "core",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
        ),
        .executableTarget(
            name: "murmuration",
            dependencies: [
                "torrent",
                "cli",
            ],
            path: "Sources/torrent-cli",
        ),
        .testTarget(name: "torrentTests", dependencies: ["torrent"]),
    ])
