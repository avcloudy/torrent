import Foundation

public final class TorrentSession: Sendable {
    public static let shared = TorrentSession()

    public let peerID: Data

    private init() {
        self.peerID = TorrentSession.generatePeerId()
    }

    private static func generatePeerId() -> Data {
        // peer id MM for murmuration, version v0.0.4 -> 0004
        let prefix = "-MM0004-".data(using: .ascii)!

        var random = Data()
        for _ in 0..<12 {
            random.append(UInt8.random(in: 0...255))
        }
        return prefix + random
    }
}
