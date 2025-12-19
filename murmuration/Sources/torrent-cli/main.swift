import Foundation
import torrent

// Testing torrent creation with Ubuntu torrent
// Need to adjust to multi-file torrents next
//if let torrent = Torrent(path: "/Users/cloudy/Downloads/ubuntu-25.10-desktop-amd64.iso.torrent") {
//    print("✅ Torrent created")
//    print(torrent.getValues())
//} else {
//    print("❌ Failed to create torrent")
//}

//if let torrent = Torrent(path: "~/Downloads/testtorrents/lots-of-numbers.torrent") {
//    print("✅ lots-of-numbers.torrent Torrent created")
//    print(torrent.getValues())
//} else {
//    print("❌ Failed to create torrent")
//}

// subdirectory: "Resources" and subdirectory: nil both seem to work here?
let torrentURL = TorrentResources.bundle.url(
    forResource: "lots-of-numbers",
    withExtension: "torrent",
    subdirectory: "Resources")

print(torrentURL!.path)

if let torrent = Torrent(path: torrentURL?.path ?? "") {
    let torrentfiles = torrent.getValues()["files"] as? [[String: Any]]
    print("✅ lots-of-numbers.torrent Torrent created")
    //    let firstpath = torrentfiles?[0]["path"] as? [String]
    //    let firstlist = (torrentfiles?[0])
    //    let firstpath = firstlist?["path"]
    //    print(firstlist!)
    //    print(firstpath!)
    //    let rawDict = try encode(data: torrent.getValues())
    //    print(rawDict)
    //    print(type(of: rawDict))
    let rawDict = torrent.getOptionalValues()
    let bencodeComp = try encode(data: rawDict)
    print(rawDict)
    let text = String(decoding: bencodeComp, as: UTF8.self)
    print(text)
} else {
    print("❌ Failed to create torrent")
}

// for debugging
// print out all resources in TorrentResources
//for resource in TorrentResources.bundle.urls(
//    forResourcesWithExtension: "torrent", subdirectory: nil) ?? []
//{
//    print("Found resource: \(resource.lastPathComponent)")
//}
