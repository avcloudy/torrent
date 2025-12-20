import Foundation
import cli

@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
@main
struct Main {
    static func main() async throws {
        await TorrentCLI.main()
    }
}
