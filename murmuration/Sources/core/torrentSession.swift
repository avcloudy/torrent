import Foundation

public class TorrentSession {
    public enum State {
        case stopped
        case running
    }

    public let metadata: [String: Any]
    public var state: State = .stopped

    init(metadata: [String: Any]) {
        self.metadata = metadata
    }

    func start() {
        state = .running
        print("Started torrent: \(metadata["name"], default: "unnamed torrent")")
    }

    func stop() {
        state = .stopped
        print("Stopped torrent: \(metadata["name"], default: "unnamed torrent")")
    }
}
