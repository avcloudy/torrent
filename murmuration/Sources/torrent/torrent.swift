import CryptoKit
import Foundation

public enum TorrentResources {
    public static let bundle: Bundle = .module
}

public enum MetadataError: Error {
    case invalidInfoDictionary
    case invalidBencode
    case unencodeableInfoDict
}

public class Torrent {
    public let announce: String
    public let announceList: [String]?
    public let comment: String?
    public let creationDate: Int?
    public let createdBy: String?
    public let length: Int?
    public let name: String
    public let pieceLength: Int
    public let pieces: Data
    public let isPrivate: Bool?
    // TODO: implement files as struct and build a Files struct in initialiser
    public let files: [[String: Any]]?
    public let encoding: String?
    public let infoHash: Data
    public let bencodedInfoDict: Data

    public init(path: String) throws(MetadataError) {
        // read torrent file
        let url = URL(fileURLWithPath: path)
        let fileData = (try? Data(contentsOf: url)) ?? Data()

        // Decode bencode binary
        guard let decoded = try? decode(data: fileData),
            let dict = try? walker(bencodedObject: decoded) as? [String: Any]
        else {
            throw MetadataError.invalidBencode
        }

        // Check if dictionary values exist, cast them as the appropriate types, and assign
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

        if let createdByData = dict["created by"] as? Data {
            self.createdBy = String(data: createdByData, encoding: .utf8)
        } else {
            self.createdBy = nil
        }

        self.creationDate = dict["creation date"] as? Int

        guard let infoDict = dict["info"] as? [String: Any] else {
            throw MetadataError.invalidInfoDictionary
        }

        self.length = infoDict["length"] as? Int ?? nil

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

        if let filesList = infoDict["files"] as? [[String: Any]] {
            self.files = filesList.map { fileDict in

                var fileInfo: [String: Any] = [:]

                // length
                if let length = fileDict["length"] as? Int {
                    fileInfo["length"] = length
                }

                // path: array of Data -> array of String
                if let pathArray = fileDict["path"] as? [Data] {
                    fileInfo["path"] = pathArray.compactMap { String(data: $0, encoding: .utf8) }
                }

                return fileInfo
            }
        } else {
            self.files = nil
        }

        if let encoding = dict["encoding"] as? Data {
            self.encoding = String(data: encoding, encoding: .utf8)
        } else {
            self.encoding = nil
        }
        guard let bencodeInfoDict = try? encode(data: infoDict) else {
            throw MetadataError.unencodeableInfoDict
        }

        infoHash = Torrent.getInfoHash(data: bencodeInfoDict)
        bencodedInfoDict = bencodeInfoDict
    }

    //    public static func == (lhs: Torrent, rhs: Torrent) -> Bool {
    //        lhs.infoHash == rhs.infoHash
    //    }

    private static func getInfoHash(data: Data) -> Data {
        Data(Insecure.SHA1.hash(data: data))
    }

    // MARK: Info dict and hashes
    private func getInfoDict() -> [String: Any] {
        let infoDict: [String: Any] = [
            "name": name,
            "piece length": pieceLength,
            "pieces": pieces,
            "files": files as Any,
            "length": length as Any,
            "private": isPrivate as Any,
        ]
        return infoDict.compactMapValues { $0 }
    }

    private var infoDict: [String: Any] {
        getInfoDict()
    }

    private func bencodeInfoDict() -> Data {
        var infoDict: Data = Data()
        do {
            infoDict = try encode(data: getInfoDict())
        } catch {
            print(error)
        }
        return infoDict
    }

    //    private var infoHash: SHA256Digest {
    //        getInfoHash()
    //    }

    // MARK: Deprecated public getter
    // Preserved for testing
    // get values directly from torrent ie torrent.announce
    public func getValues() -> [String: Any] {
        let result: [String: Any] = [
            "announce": announce,
            "announce-list": announceList as Any,
            "comment": comment as Any,
            "creation date": creationDate as Any,
            "created by": createdBy as Any,
            "encoding": encoding as Any,
            "info": infoDict,
        ]
        return result.compactMapValues { $0 }
    }
}
