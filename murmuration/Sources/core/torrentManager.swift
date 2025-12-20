import Foundation
import torrent

// MARK: torrentManager
// ##############################
// torrentManager.swift
//
// defines a singleton actor that manages torrent state
// commands.swift CLI commands call actions in here
// ##############################

public actor TorrentManager {
    public static let shared = TorrentManager()

    private var torrents: [String: TorrentInstance] = [:]

    private init() {}

    public func addTorrent(from path: String) throws {
        let torrent = try Torrent(path: path)
        let instance = TorrentInstance(metadata: torrent)
        torrents[torrent.name] = instance

        if let url = TorrentTracker.announceUrl(
            metadata: torrent, peerID: TorrentSession.shared.peerID)
        {
            print("Tracker announce URL:", url)
        }
    }

    public func announceToTracker(name: String) async throws {
        guard let torrent = torrents[name] else {
            throw TrackerError.torrentNotFound
        }
        guard
            let url = TorrentTracker.announceUrl(
                metadata: torrent.metadata, peerID: TorrentSession.shared.peerID)
        else {
            throw TrackerError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        // parse tracker response (bencoded dictionary)
        if let string = String(data: data, encoding: .utf8) {
            print("Tracker response as UTF-8:\n\(string)")
        } else {
            print(
                "Tracker response contains non-UTF8 bytes. Printing raw with hex for binary sections:"
            )

            var output = ""
            for byte in data {
                if byte >= 32 && byte <= 126 {
                    // printable ASCII
                    output.append(Character(UnicodeScalar(byte)))
                } else {
                    // non-printable: hex
                    output.append(String(format: "\\x%02x", byte))
                }
            }
            print(output)
        }
    }

    public func startTorrent(name: String) {
        torrents[name]?.start()
    }

    public func listTorrents() -> [TorrentInstance] {
        Array(torrents.values)
    }

}
