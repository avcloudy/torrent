import Foundation

enum encodeError: Error {
    case nonBencodeableDataType
    case nonASCIIString(string: String)
}

/// Bencode creator function.
/// - Parameter data: A String, Int, Array[String, Int, Array, Dict] or Dict[String: String, Int, Array, Dict].
/// - Throws: Throws if you provide it something that can't be encoded with Bencode. That includes an Array or Dict that contains a non-
/// Bencodeable object, despite signature being Any
/// - Returns: A String containing raw Bencode test for ASCII conversion
public func encode(data: Any) throws -> String {
    switch data {
    case let s as String:
        return try encodeString(data: s)
    case let i as Int:
        return try encodeInt(data: i)
    case let l as [Any]:
        return try encodeList(data: l)
    case let d as [String: Any]:
        return try encodeDict(data: d)
    default:
        throw encodeError.nonBencodeableDataType
    }
}

// MARK: Helper functions for encode(data:)
private func encodeString(data: String) throws -> String {
    let lengthOfString = String(data.count)
    let encodedString = lengthOfString + ":" + data
    // For now, just making simple swift typed returns to check patterns
//    if let asciiString = encodedString.data(using: .ascii) {
//        return .bytes(asciiString)
//    } else {
//        throw encodeError.nonASCIIString(string: data)
//    }
    return encodedString
}

private func encodeInt(data: Int) throws -> String {
    let encodedString = "i" + String(data) + "e"
    return encodedString
}

private func encodeList(data: [Any]) throws -> String {
    var encodedString = "l"
    for item in data {
        let encodedItem = (try? encode(data: item)) ?? ""
        encodedString = encodedString + encodedItem
    }
    encodedString = encodedString + "e"
    return encodedString
}

private func encodeDict(data: [String: Any]) throws -> String {
    var encodedString = "d"
    for (key, value) in data {
        let encodedKey = (try? encode(data: key)) ?? ""
        let encodedValue = (try? encode(data: value)) ?? ""
        encodedString = encodedString + encodedKey + encodedValue
    }
    encodedString = encodedString + "e"
    return encodedString
}
