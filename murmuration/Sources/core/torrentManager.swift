import Foundation
import torrent

public actor TorrentManager {
    public static let shared = TorrentManager()

    private var sessions: [String: TorrentSession] = [:]

    private init() {}

    public func addTorrent(from path: String) throws {
        if let torrent = Torrent(path: path) {
            let session = TorrentSession(metadata: torrent)
            sessions[torrent.getInfoHash()] = session
        }
    }

    public func startTorrent(infoHash: String) {
        sessions[infoHash]?.start()
    }

    public func listTorrents() -> [TorrentSession] {
        Array(sessions.values)
    }

}
