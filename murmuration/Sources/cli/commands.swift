import ArgumentParser
import Foundation
import core

@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
public struct TorrentCLI: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "torrent",
        subcommands: [Add.self, Start.self, List.self, Announce.self],
    )

    public init() {}

    // MARK: - Run interactive if no arguments
    public func run() async throws {
        // Check if the process was invoked with subcommands
        if CommandLine.arguments.count > 1 {
            // There are arguments; ArgumentParser will handle them
            return
        }

        // No arguments -> enter interactive REPL
        await runREPL()
    }
}

private func runREPL() async {
    print("🎵 Murmuration Interactive CLI")
    print("Type 'help' for commands, 'exit' to quit.\n")

    while true {
        print("murmuration % ", terminator: "")
        guard let line = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
            !line.isEmpty
        else { continue }

        if line.lowercased() == "exit" { break }
        if line.lowercased() == "help" {
            let subcommandNames = TorrentCLI.configuration.subcommands.compactMap {
                $0.configuration.commandName
            }
            print("Commands: \(subcommandNames.joined(separator: ", "))")
            print("  exit - Quit")
            continue
        }

        // Split input like argv
        let argv = line.split(separator: " ").map { String($0) }
        do {
            // Parse command from argv
            let command = try TorrentCLI.parseAsRoot(argv)

            // Execute the async command
            if var asyncCommand = command as? any AsyncParsableCommand {
                try await asyncCommand.run()
            }
        } catch {
            print("❌ Invalid command:", error)
        }
    }

    print("👋 Exiting interactive CLI.")
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
    // Just doing name to start, because i need to fucking type it
    // can get fancy with info hash later
    @Argument(help: "name")
    var name: String

    func run() async {
        await TorrentManager.shared.startTorrent(name: name)
    }
}

struct List: AsyncParsableCommand {
    func run() async {
        let sessions = await TorrentManager.shared.listTorrents()
        for s in sessions {
            let infoHashHex = s.metadata.infoHash.map { String(format: "%02x", $0) }.joined()
            print("\(s.metadata.name) - \(s.state) - info hash: \(infoHashHex)")
        }
    }
}

struct Announce: AsyncParsableCommand {
    @Argument(help: "Name of torrent to announce")
    var name: String

    func run() async throws {
        try await TorrentManager.shared.announceToTracker(name: name)
    }
}
