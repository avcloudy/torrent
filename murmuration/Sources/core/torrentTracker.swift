import Foundation
import torrent

// MARK: torrentTracker
// ##############################
// torrentTracker.swift
//
// Whenever Murmuration interacts with a tracker
// eg. announcing, scraping, etc
// defined as a method on TorrentTracker
// TODO: more robust port logic
// ##############################

public enum TrackerError: Error {
    case invalidURL
    case invalidResponse
    case torrentNotFound
}
public struct TorrentTracker {
    public static func announce(metadata: Torrent, peerID: Data, port: Int = 6881) async throws
        -> Data
    {
        // Build the announce URL
        guard let url = announceUrl(metadata: metadata, peerID: peerID) else {
            throw TrackerError.invalidURL
        }

        // Send GET request
        let (data, response) = try await URLSession.shared.data(from: url)

        // Check HTTP response status
        guard let httpResponse = response as? HTTPURLResponse,
            200..<300 ~= httpResponse.statusCode
        else {
            throw TrackerError.invalidResponse
        }
        return data
    }

    public static func announceUrl(metadata: Torrent, peerID: Data, port: Int = 6881) -> URL? {
        guard let announceBase = URL(string: metadata.announce) else { return nil }

        var components = URLComponents(url: announceBase, resolvingAgainstBaseURL: false)
        components?.percentEncodedQueryItems = [
            URLQueryItem(name: "info_hash", value: self.percentEncode(data: metadata.infoHash)),
            URLQueryItem(name: "peer_id", value: self.percentEncode(data: peerID)),
            URLQueryItem(name: "port", value: "\(port)"),
            URLQueryItem(name: "uploaded", value: "0"),
            URLQueryItem(name: "downloaded", value: "0"),
            URLQueryItem(name: "left", value: "\(metadata.length ?? 0)"),
            URLQueryItem(name: "compact", value: "1"),
            URLQueryItem(name: "event", value: "started"),
        ]

        return components?.url
    }

    // this could possibly move to encode
    // probably need a bencoder, hex encoder, percent encoder
    // and then bdecoder, hex decoder, percent decoder
    public static func percentEncode(data: Data) -> String {
        data.map { String(format: "%%%02X", $0) }.joined()
    }
}
