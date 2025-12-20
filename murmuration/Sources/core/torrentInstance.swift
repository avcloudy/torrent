import Foundation
import torrent

// MARK: torrentInstance
// ##############################
// torrentInstance.swift
//
// defines an instance of a torrent
// contains data such as state (stopped, running)
// downloaded percent, left to download etc
// ##############################

public final class TorrentInstance: @unchecked Sendable {
    public enum State {
        case paused
        case running
    }

    public let metadata: Torrent
    public var state: State = .paused

    init(metadata: Torrent) {
        self.metadata = metadata
    }

    func start() {
        state = .running
        print("Started torrent: \(metadata.name, default: "unnamed torrent")")
    }

    func pause() {
        state = .paused
        print("Stopped torrent: \(metadata.name, default: "unnamed torrent")")
    }
}
