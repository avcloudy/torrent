import Foundation

public class Torrent {
    let announce: String
    let announceList: [String]?
    let comment: String?
    let creationDate: Int?
    let createdBy: String?
    let length: Int
    let name: String
    let pieceLength: Int
    let pieces: Data
    let isPrivate: Bool?

    public init?(path: String) {
        //        let url = URL(fileURLWithPath: "/Users/cloudy/Downloads/ubuntu-25.10-desktop-amd64.iso.torrent")
        let fileData =
            (try? Data(
                contentsOf: URL(
                    fileURLWithPath:
                        "/Users/cloudy/Downloads/ubuntu-25.10-desktop-amd64.iso.torrent")))
            ?? Data()

        // Decode bencode binary
        guard let decoded = try? decode(data: fileData),
            let dict = try? walker(bencodedObject: decoded) as? [String: Any]
        else {
            return nil
        }

        if let announceData = dict["announce"] as? Data,
            let announceString = String(data: announceData, encoding: .utf8)
        {
            self.announce = announceString
        } else {
            self.announce = ""
        }

        if let announceListArray = dict["announce-list"] as? [[Data]] {
            self.announceList = announceListArray.compactMap { innerArray in
                innerArray.compactMap { String(data: $0, encoding: .utf8) }.first
            }
        } else {
            self.announceList = nil
        }

        if let commentData = dict["comment"] as? Data {
            self.comment = String(data: commentData, encoding: .utf8)
        } else {
            self.comment = nil
        }

        if let createdByData = dict["Created By"] as? Data {
            self.createdBy = String(data: createdByData, encoding: .utf8)
        } else {
            self.createdBy = nil
        }

        self.creationDate = dict["creation date"] as? Int

        guard let infoDict = dict["info"] as? [String: Any] else { return nil }

        self.length = infoDict["length"] as? Int ?? 0

        if let nameData = infoDict["name"] as? Data {
            self.name = String(data: nameData, encoding: .utf8) ?? ""
        } else {
            self.name = ""
        }

        self.pieceLength = infoDict["piece length"] as? Int ?? 0

        if let piecesData = infoDict["pieces"] as? Data {
            self.pieces = piecesData
        } else {
            self.pieces = Data()
        }
        self.isPrivate = infoDict["private"] as? Bool
    }

    public func getValues() -> [String: Any] {
        return [
            "announce": announce,
            "announceList": announceList ?? [],
            "comment": comment ?? "",
            "creationDate": creationDate ?? 0,
            "createdBy": createdBy ?? "",
            "length": length,
            "name": name,
            "pieceLength": pieceLength,
            "private": isPrivate ?? false,
        ]
    }
}
