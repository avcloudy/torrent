// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "murmuration", platforms: [.macOS(.v26)],
    products: [
        .library(name: "torrent", targets: ["torrent"]),
        .library(name: "core", targets: ["core"]),
        .library(name: "cli", targets: ["cli"]),
        .executable(name: "torrent-cli", targets: ["torrent-cli"]),
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
            name: "cli", dependencies: ["core"],
        ),
        .executableTarget(
            name: "torrent-cli",
            dependencies: [
                "torrent",
                "cli",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
        ),
        .testTarget(name: "torrentTests", dependencies: ["torrent"]),
    ])
