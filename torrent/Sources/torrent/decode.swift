import Foundation

// MARK: Error enum
enum bencodeError: Error {
    case badBencodeStart(index: Int)
    case nonASCII
    case streamEmpty
    case malformedString(index: Int)
    case malformedStringLength(index: Int)
    case malformedInt(index: Int)
    case intMissingEnd(index: Int)
    case malformedList(index: Int)
    case malformedDict(index: Int)
    case dictKeyNotString(index: Int)
    case dictKeyNotStringWalker
}

// MARK: Decode function
/// Decodes a Bencode encoded strong into constituent bencode objects, which is a thin wrapper around their native types
/// - Parameter data: A String containing only ASCII characters encoded via Bencode
///  String: Starts with length of string, : then string. this is a string! -> 17:this is a string!
///  Integer: Starts with i, then contains int, ends with e. 42 -> i42e
///  List: Starts with l, then contains contents of list, ends with e. can contain any Bencode object, including a list and a dictionary.
///  ["Surface",["Nested", "List"]] -> l7:Surfacel6:Nested4:Listee
///  Dictionary: Starts with d, then contains a string as key, then first value. Can contain any bencode object, including lists and dictionaries in value.
///  ["Key": "Value", "Dictionary": ["Type": "Dictionary"],"List":["Sample", "List"]] -> d3:Key5:Value10:Dictionaryd4:type10:Dictionarye4:Listl6:Sample4:Listee
/// - Throws: If it happens at a specific index in string, returns where the problem is. This will usually be the end of the object with an error.
/// - Returns: Bencode object. Return base value with eg guard let .string(rawvalue) = bencodeString
public func decode(data: String) throws -> bencode? {
    guard let asciiData = data.data(using: .ascii) else {
        throw bencodeError.nonASCII
    }
    let stream = asciiData.map { Character(UnicodeScalar($0)) }
    
    let root = try dechunk(stream: stream, index: 0).0
    return root
}

// MARK: - Helper functions for decode(data: String)

private func dechunk(stream: [Character], index: Int) throws -> (bencode?, Int) {
    let inNumberRange: ClosedRange<Character> = "0"..."9"
    // check we aren't at the end of the array, and if we have reached the second last entry and
    // are callign dechunk, must be malformed stream (effectively empty)
    guard index < stream.count else {
        throw bencodeError.streamEmpty
    }
    let nextCharacter = stream[index]
    
    switch nextCharacter {
    case inNumberRange:
        return try decodeString(stream: stream, index: index)
    case "i":
        return try decodeInt(stream: stream, index: index)
    case "l":
        return try decodeList(stream: stream, index: index)
    case "d":
        return try decodeDict(stream: stream, index: index)
    default:
        throw bencodeError.badBencodeStart(index: index)
    }
}

private func decodeString(stream: [Character], index: Int) throws -> (bencode?, Int) {
    // grab index to mutate
    var index = index
    // bencode string starts with an int, length of the string, then a colon, then the string
    // 24:this is a bencode string
    // so grab the int characters and when nextCharacter not int check is colon
    var stringLength = ""
    
    guard index < stream.count else {
        throw bencodeError.streamEmpty
    }
    while stream[index].isNumber {
        stringLength.append(stream[index])
        index += 1
    }
    guard stream[index] == ":" else {
        throw bencodeError.malformedString(index: index)
    }
    index += 1
    // check stringLength can actually cast to Int
    guard let length = Int(stringLength) else {
        throw bencodeError.malformedStringLength(index: index)
    }
    // make string of characters and advance the index that length
    let stringChars = stream[index..<index+length]
    index += length
    return (.string(String(stringChars)) ,index)
}

private func decodeInt(stream: [Character], index: Int) throws -> (bencode?, Int) {
    var index = index
    
    guard index < stream.count else {
        throw bencodeError.streamEmpty
    }
    // bencode int starts with an i, contains the number, then ends with an e eg:
    // i45e
    
    guard stream[index] == "i" else {
        throw bencodeError.malformedInt(index: index)
    }
    index += 1
    
    var intChars = ""
    while stream[index].isNumber {
        intChars.append(stream[index])
        index += 1
    }
    guard let int = Int(intChars) else {
        throw bencodeError.malformedInt(index: index)
    }
    guard stream[index] == "e" else {
        throw bencodeError.intMissingEnd(index: index)
    }
    index += 1
    
    return (.int(int), index)
}

private func decodeList(stream: [Character], index: Int) throws -> (bencode?, Int) {
    var index = index
    
    guard index < stream.count else {
        throw bencodeError.streamEmpty
    }
    // bencode list starts with an l, contains any number of bencode string, int, list or dict
    // objects (including none) and ends with an e. No seperators.
    
    guard stream[index] == "l" else {
        throw bencodeError.malformedList(index: index)
    }
    index += 1
    // check next character is not e, if it is, return an empty bencode list
    guard stream[index] != "e" else {
        return (.list([]), index)
    }
    var list: [bencode] = []
    while stream[index] != "e" {
        let (bencodeObject, newIndex) = try dechunk(stream: stream, index: index)
        index = newIndex
        if let value = bencodeObject {
            list.append(value)
        }
    }
    index += 1
    return (.list(list), index)
}

private func decodeDict(stream: [Character], index: Int) throws -> (bencode?, Int) {
    var index = index
    
    guard index < stream.count else {
        throw bencodeError.streamEmpty
    }
    // bencode dict starts with a d, the key is the next bencode object, which must be a string
    // and the value is the next bencode object, which may be any bencode object
    guard stream[index] == "d" else {
        throw bencodeError.malformedDict(index: index)
    }
    index += 1
    var dict: [bencode: bencode] = [:]
    guard stream[index] != "e" else {
        return (.dict(dict), index)
    }
    while stream[index] != "e" {
        let (key, newIndex) = try dechunk(stream: stream, index: index)
        guard case .string = key else {
            throw bencodeError.dictKeyNotString(index: index)
        }
        guard newIndex < stream.count else {
            throw bencodeError.streamEmpty
        }
        index = newIndex
        let (value, secondNewIndex) = try dechunk(stream: stream, index: index)
        dict[key ?? .string("")] = value ?? .string("")
        if let keyObject = key  {
            dict[keyObject] = value
        }
        guard secondNewIndex < stream.count else {
            throw bencodeError.streamEmpty
        }
        index = secondNewIndex
    }
    index += 1
    return (.dict(dict), index)
}

// MARK: - Walker function for recursive extraction of lists and dictionaries
/// Recursively walks through BencodeObject
/// - Parameter bencodedObject: Any valid bencode object
/// - Throws: If dict key isn't a string, throws error
/// - Returns: As far as it can, returns the raw object. Because of the structure of Bencode, and Swift's type safety, lists and dicts
/// return as [Any] and [String: Any], which is unavoidable. You probably need to know what's in the bencode object to extract the raw Swift type.
public func walker(bencodedObject: bencode) throws -> Any {
    switch bencodedObject {
    case let .string(s):
        return s
    case let .int(i):
        return i
    case let .list(l):
        var list: [Any] = []
        for item in l {
            list.append(try walker(bencodedObject: item))
        }
        return list
    case let .dict(d):
        var dict: [String: Any] = [:]
        for (key, val) in d {
            guard case let .string(keyString) = key else {
                throw bencodeError.dictKeyNotStringWalker
            }
            dict[keyString] = try walker(bencodedObject: val)
        }
        return dict
    }
}
