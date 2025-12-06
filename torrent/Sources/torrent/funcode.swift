import Foundation

enum funcodeError: Error {
    case badFuncodeStart(index: Int)
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

public enum funcode: Hashable {
    case string(String)
    case int(Int)
    indirect case list([funcode])
    indirect case dict([funcode: funcode])
}

public func decode(data: String) throws -> funcode? {
    guard let asciiData = data.data(using: .ascii) else {
        throw funcodeError.nonASCII
    }
    let stream = asciiData.map { Character(UnicodeScalar($0)) }
    
    let root = try dechunk(stream: stream, index: 0).0
    return root
}

private func dechunk(stream: [Character], index: Int) throws -> (funcode?, Int) {
    let inNumberRange: ClosedRange<Character> = "0"..."9"
    // check we aren't at the end of the array, and if we have reached the second last entry and
    // are callign dechunk, must be malformed stream (effectively empty)
    guard index < stream.count else {
        throw funcodeError.streamEmpty
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
        throw funcodeError.badFuncodeStart(index: index)
    }
}

private func decodeString(stream: [Character], index: Int) throws -> (funcode?, Int) {
    // grab index to mutate
    var index = index
    // bencode string starts with an int, length of the string, then a colon, then the string
    // 24:this is a bencode string
    // so grab the int characters and when nextCharacter not int check is colon
    var stringLength = ""
    
    guard index < stream.count else {
        throw funcodeError.streamEmpty
    }
    while stream[index].isNumber {
        stringLength.append(stream[index])
        index += 1
    }
    guard stream[index] == ":" else {
        throw funcodeError.malformedString(index: index)
    }
    index += 1
    // check stringLength can actually cast to Int
    guard let length = Int(stringLength) else {
        throw funcodeError.malformedStringLength(index: index)
    }
    // make string of characters and advance the index that length
    let stringChars = stream[index..<index+length]
    index += length
    return (.string(String(stringChars)) ,index)
}

private func decodeInt(stream: [Character], index: Int) throws -> (funcode?, Int) {
    var index = index
    
    guard index < stream.count else {
        throw funcodeError.streamEmpty
    }
    // bencode int starts with an i, contains the number, then ends with an e eg:
    // i45e
    
    guard stream[index] == "i" else {
        throw funcodeError.malformedInt(index: index)
    }
    index += 1
    
    var intChars = ""
    while stream[index].isNumber {
        intChars.append(stream[index])
        index += 1
    }
    guard let int = Int(intChars) else {
        throw funcodeError.malformedInt(index: index)
    }
    guard stream[index] == "e" else {
        throw funcodeError.intMissingEnd(index: index)
    }
    index += 1
    
    return (.int(int), index)
}

private func decodeList(stream: [Character], index: Int) throws -> (funcode?, Int) {
    var index = index
    
    guard index < stream.count else {
        throw funcodeError.streamEmpty
    }
    // bencode list starts with an l, contains any number of bencode string, int, list or dict
    // objects (including none) and ends with an e. No seperators.
    
    guard stream[index] == "l" else {
        throw funcodeError.malformedList(index: index)
    }
    index += 1
    var list: [funcode] = []
    while stream[index] != "e" {
        let (funcodeObject, newIndex) = try dechunk(stream: stream, index: index)
        index = newIndex
        if let value = funcodeObject {
            list.append(value)
        }
    }
    index += 1
    return (.list(list), index)
}

private func decodeDict(stream: [Character], index: Int) throws -> (funcode?, Int) {
    var index = index
    
    guard index < stream.count else {
        throw funcodeError.streamEmpty
    }
    // bencode dict starts with a d, the key is the next bencode object, which must be a string
    // and the value is the next bencode object, which may be any bencode object
    guard stream[index] == "d" else {
        throw funcodeError.malformedDict(index: index)
    }
    index += 1
    var dict: [funcode: funcode] = [:]
    while stream[index] != "e" {
        let (key, newIndex) = try dechunk(stream: stream, index: index)
        guard case .string = key else {
            throw funcodeError.dictKeyNotString(index: index)
        }
        index = newIndex
        let (value, secondNewIndex) = try dechunk(stream: stream, index: index)
        dict[key ?? .string("")] = value ?? .string("")
//        if let keyObject = key  {
//            dict[keyObject] = value
//            print("\(keyObject), \(value, default: "")")
//        }
        index = secondNewIndex
        
    }
    index += 1
    return (.dict(dict), index)
}

public func walker(bencodedObject: funcode) throws -> Any {
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
                throw funcodeError.dictKeyNotStringWalker
            }
            dict[keyString] = try walker(bencodedObject: val)
        }
        return dict
    }
}
