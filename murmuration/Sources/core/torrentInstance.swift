import Foundation
import torrent

public final class TorrentInstance: @unchecked Sendable {
    public enum State {
        case stopped
        case running
    }

    public let metadata: Torrent
    public var state: State = .stopped

    init(metadata: Torrent) {
        self.metadata = metadata
    }

    func start() {
        state = .running
        print("Started torrent: \(metadata.name, default: "unnamed torrent")")
    }

    func stop() {
        state = .stopped
        print("Stopped torrent: \(metadata.name, default: "unnamed torrent")")
    }
}
