// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "torrent",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .library(name: "torrent", targets: ["torrent"]),
        .executable(name: "torrent-cli", targets: ["torrent-cli"]),
    ],
    targets: [
        .target(name: "torrent"),
        .executableTarget(
            name: "torrent-cli",
            dependencies: ["torrent"]
        ),
        .testTarget(
            name: "torrentTests",
            dependencies: ["torrent"]
        ),
    ]
)
