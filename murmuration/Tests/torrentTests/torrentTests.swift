import Foundation
import Testing

@testable import torrent

class BencodeEncodeTests {
    @Test
    func encodeStringData() throws {
        let exampleString = Data("This is a string!".utf8)
        let exampleBencode = Data("17:This is a string!".utf8)
        let encodedString = try encode(data: exampleString)
        #expect(exampleBencode == encodedString)
    }

    @Test
    func encodeString() throws {
        let exampleString = "This really is a string!"
        let exampleBencode = Data("24:This really is a string!".utf8)
        let encodedString = try encode(data: exampleString)
        #expect(exampleBencode == encodedString)
    }

    @Test
    func encodeInt() throws {
        let exampleInt = 42
        let exampleBencode = Data("i42e".utf8)
        let encodedInt = try encode(data: exampleInt)
        #expect(exampleBencode == encodedInt)
    }

    @Test
    func encodeList() throws {
        let exampleList = ["this", "is", "a", "list"]
        let exampleBencode = Data("l4:this2:is1:a4:liste".utf8)
        let encodedList = try encode(data: exampleList)
        #expect(exampleBencode == encodedList)
    }

    @Test
    func encodeDist() throws {
        // note ordering
        let exampleDict: [String: Any] = [
            "key": "value", "key2": "value", "intkey": 42, "listkey": ["this", "is", "a", "list"],
        ]
        let exampleBencode = Data(
            "d6:intkeyi42e3:key5:value4:key25:value7:listkeyl4:this2:is1:a4:listee".utf8)
        let encodedDict = try encode(data: exampleDict)
        #expect(exampleBencode == encodedDict)
    }
    @Test
    func encodeIntNegative() throws {
        let exampleInt = -42
        let exampleBencode = Data("i-42e".utf8)
        let encodedInt = try encode(data: exampleInt)
        #expect(exampleBencode == encodedInt)
    }
}

class TorrentReadTests {

    // bundling resources within Swift because it's hard to get a good relative path
    // to resources otherwise
    // TorrentResources is declared in torrent.swift
    // torrents exist in torrent/Resources/
    func getTorrent() -> String {
        guard
            let torrentURL = TorrentResources.bundle.url(
                forResource: "ubuntu-25.10-desktop-amd64.iso",
                withExtension: "torrent",
                subdirectory: "Resources")
        else {
            return ""
        }
        return torrentURL.path
    }

    @Test
    func announceName() {
        let torrent = try? Torrent(path: getTorrent())
        let torrentDict = torrent?.getValues()
        #expect(torrentDict?["announce"] as? String == "https://torrent.ubuntu.com/announce")
    }

    @Test
    func announceList() {
        let torrent = try? Torrent(path: getTorrent())
        let torrentDict = torrent?.getValues()
        #expect(
            torrentDict?["announceList"] as? [String] == [
                "https://torrent.ubuntu.com/announce", "https://ipv6.torrent.ubuntu.com/announce",
            ])
    }

    @Test
    func comment() {
        let torrent = try? Torrent(path: getTorrent())
        let torrentDict = torrent?.getValues()
        #expect(torrentDict?["comment"] as? String == "Ubuntu CD releases.ubuntu.com")
    }

    @Test
    func creationDate() {
        let torrent = try? Torrent(path: getTorrent())
        let torrentDict = torrent?.getValues()
        #expect(torrentDict?["creationDate"] as? Int == 1_759_993_240)
    }

    @Test
    func createdBy() {
        let torrent = try? Torrent(path: getTorrent())
        let torrentDict = torrent?.getValues()
        #expect(torrentDict?["createdBy"] as? String == "mktorrent 1.1")
    }

    @Test
    func length() {
        let torrent = try? Torrent(path: getTorrent())
        let torrentDict = torrent?.getValues()
        #expect(torrentDict?["length"] as? Int == 5_702_520_832)
    }

    @Test
    func name() {
        let torrent = try? Torrent(path: getTorrent())
        let torrentDict = torrent?.getValues()
        #expect(torrentDict?["name"] as? String == "ubuntu-25.10-desktop-amd64.iso")
    }

    @Test
    func pieceLength() {
        let torrent = try? Torrent(path: getTorrent())
        let torrentDict = torrent?.getValues()
        #expect(torrentDict?["pieceLength"] as? Int == 262144)
    }

    @Test
    func isPrivate() {
        let torrent = try? Torrent(path: getTorrent())
        let torrentDict = torrent?.getValues()
        #expect(torrentDict?["private"] as? Bool == false)
    }
}

class TorrentEncodeTests {

    func getTorrent() -> String {
        guard
            let torrentURL = TorrentResources.bundle.url(
                forResource: "lots-of-numbers",
                withExtension: "torrent",
                subdirectory: "Resources")
        else {
            return ""
        }
        return torrentURL.path
    }

    func getFile() -> URL {
        guard
            let torrentURL = TorrentResources.bundle.url(
                forResource: "lots-of-numbers",
                withExtension: "torrent",
                subdirectory: "Resources")
        else {
            return URL(string: "")!
        }
        return torrentURL
    }

    @Test
    func OutputEquivalentToInput() throws {
        let torrent = try? Torrent(path: getTorrent())
        let rawDict = torrent?.getValues()
        let bencodeComp = try encode(data: rawDict!)
        let torrentFileData = try Data(contentsOf: getFile())
        #expect(bencodeComp == torrentFileData)
    }
}

class MultiFileTorrents {
    class LotsOfNumbersTorrent {
        // testing im actually getting the correct values out of the test torrents of course, but side benefit is that im
        // figuring out how to usefully extract the damn values
        func getTorrent() -> String {
            guard
                let torrentURL = TorrentResources.bundle.url(
                    forResource: "lots-of-numbers",
                    withExtension: "torrent",
                    subdirectory: "Resources")
            else {
                return ""
            }
            return torrentURL.path
        }

        @Test
        func creationDate() {
            let torrent = try? Torrent(path: getTorrent())
            let torrentDict = torrent?.getValues()
            #expect(torrentDict?["creationDate"] as? Int == 1_458_348_895_130)
        }

        @Test
        func encoding() {
            let torrent = try? Torrent(path: getTorrent())
            let torrentDict = torrent?.getValues()
            #expect(torrentDict?["encoding"] as? String == "UTF-8")
        }

        @Test
        func name() {
            let torrent = try? Torrent(path: getTorrent())
            let torrentDict = torrent?.getValues()
            #expect(torrentDict?["name"] as? String == "lots-of-numbers")
        }

        @Test
        func filesnames() {
            let torrent = try? Torrent(path: getTorrent())
            let torrentDict = torrent?.getValues()["files"] as? [[String: Any]]
            let firstlist = (torrentDict?[0])
            let firstpath = firstlist?["path"] as? [String]
            #expect(firstpath == ["big numbers", "10.txt"])
        }
    }
}
