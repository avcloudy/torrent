import ArgumentParser
import Foundation
import core

public struct TorrentCLI: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "torrent",
        subcommands: [Add.self, Start.self, List.self]
    )

    public init() {}
}

struct Add: AsyncParsableCommand {
    @Argument(help: "Path to .torrent file.")
    var path: String

    func run() async throws {
        try await TorrentManager.shared.addTorrent(from: path)
        print("✅ Torrent created")
    }
}

struct Start: AsyncParsableCommand {
    @Argument(help: "Info Hash")
    var infoHash: String

    func run() async {
        await TorrentManager.shared.startTorrent(infoHash: infoHash)
    }
}

struct List: AsyncParsableCommand {
    func run() async {
        let sessions = await TorrentManager.shared.listTorrents()
        for s in sessions {
            print("\(s).metadata.name) - \(s.state)")
        }
    }
}
