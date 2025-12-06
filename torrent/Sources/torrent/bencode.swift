import Foundation

// Create bencodeData Type so that I can create arrays containing all four subtypes
// probably has an excessive effect on memory allocation and definitely keeps me off
// the stack
// do i actually need to do this? can just have bencoder return a raw object
// of the correct type since it returns the first bencoded object it finds
// TODO: - Create a bencode .swift file that uses only functions - perf test
public enum bencodeDataType: Hashable {
    case string(String)
    case int(Int)
    indirect case dict(Dictionary<bencodeDataType, bencodeDataType>)
    indirect case list(Array<bencodeDataType>)
    
    public var nativeValue: Any {
            switch self {
            case .string(let s):
                return s
            case .int(let i):
                return i
            case .list(let arr):
                return arr.map { $0.nativeValue }
            case .dict(let dict):
                var nativeDict: [String: Any] = [:]
                for (key, value) in dict {
                    guard case let .string(keyString) = key else {
                                    fatalError("Dictionary key must be a string")
                                }
                    nativeDict[keyString] = value.nativeValue
                }
                return nativeDict
            }
        }
}

// needed to create easy returns of custom types
// wonder if I can just declare CSC next to Hashable?
extension bencodeDataType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .string(let s):
            return "\(s)"

        case .int(let i):
            return "\(i)"

        case .list(let elements):
            let body = elements.map { $0.description }.joined(separator: ", ")
            return "[\(body)]"

        case .dict(let dict):
            // sort keys (optional) so printing is stable
            let pairs = dict.map { key, value in
                "\(key.description): \(value.description)"
            }.joined(separator: ", ")
            return "{\(pairs)}"
        }
    }
}

/// An ASCII string encoded with 'Bencode'
/// Strings are declared with an integer, length of string then the string literal i:str, for example 5:tests
/// Integers are declared with the character i, the integer, then the integer, and ending with i,
/// i#e, for example i3e. Leading zeroes invalid, no i03e.
/// Lists are declared with the character l, with : as a delimited, and may contain any Bencode
/// type. For instance l4:spam:4:eggse or ll4:spam:4:eggsel5:green:4:eggs:3:hame
/// Dictionaries are declared with the character d, the key and then the value, and end with e.
/// The key must be a string, and the value can be any Bencoded object,
/// For example d4:spam:4:eggse
public struct Bencode {
    // not sure I want to associate every Bencode struct with a data stream
    // probably need to make it inout wherever I first introduce it
    // maybe just chuck it in decode
    public init(data: String) {
        self.data = data
    }
    let data: String
    
    /// Translate a Bencode object into native data structures
    /// - Parameter data: ASCII Bencode string
    public func decode() -> bencodeDataType {
        guard let asciiData = data.data(using: .ascii) else {
            fatalError("Bencode error: Input stream not ascii encoded.")
        }
        
        // Convert ASCII bytes to Characters for your stream
        var stream = asciiData.map { Character(UnicodeScalar($0)) }
        stream.reverse()

        let root = dechunk(stream: &stream)
        return root
    }
    
//    public func unwrap(bencode: bencodeDataType) -> Any {
//        
//    }
    /// Recursively interpret Bencode objects
    /// - Parameter data: An array of characters, reversed to optimise popLast()
    /// - Returns: A complete bencodeDataType -> each decode function returns the first bencodeDataType it finds
    private func dechunk(stream: inout [Character]) -> bencodeDataType {
        let isNumberRange: ClosedRange<Character> = "0"..."9"

        guard let flag = stream.last else {
            fatalError("Unexpected end of stream.")
        }

        switch flag {
        case isNumberRange:
            return decodeString(stream: &stream)
        case "i":
            return decodeInt(stream: &stream)
        case "d":
            return decodeDict(stream: &stream)
        case "l":
            return decodeList(stream: &stream)
        default:
            fatalError("Invalid Bencode start character: \(flag).")
        }
    }
    
    private func decodeString(stream: inout [Character]) -> bencodeDataType {
        // Build the full length number
        var lenStr = ""
        while let c = stream.last, c.isNumber {
            lenStr.append(stream.popLast()!)
        }

        // next char must be ":"
        guard stream.popLast() == ":" else {
            fatalError("Invalid bencode string.")
        }

        // parse length
        guard let length = Int(lenStr) else {
            fatalError("Bencode string length identifier misformed.")
        }

        // read exactly <length> bytes
        var result = ""
        for _ in 0..<length {
            result.append(stream.popLast()!)
        }

        return .string(result)
    }
    
    private func decodeInt(stream: inout Array<Character>) -> bencodeDataType {
        var number = ""
        
        guard stream.last == "i" else{
            fatalError("Invalid int construction, character = \(stream.last, default: "nil")")
        }
        _ = stream.popLast()
        while let c = stream.popLast() {
            if c == "e" {break}
            number.append(c)
        }
        return .int(Int(number) ?? 0 )
    }
    
    private func decodeDict(stream: inout [Character]) -> bencodeDataType {
        var dict: [bencodeDataType: bencodeDataType] = [:]
        
        // consume first d
        _ = stream.popLast()

        while let next = stream.last, next != "e" {
            // dictionary must end on 'e'

            // key must be a string
            let keyObj = dechunk(stream: &stream)
            guard case .string = keyObj else {
                fatalError("Bencode dict keys must be strings")
            }

            // value can be anything
            let valueObj = dechunk(stream: &stream)

            // remember when writing, for complete conformance, keys must be
            // ordered alphabetically
            dict[keyObj] = valueObj
        }

        // consume the final 'e'
        // not sure if this is better than just stream.popLast()
        _ = stream.popLast()

        return .dict(dict)
    }
    
    private func decodeList(stream: inout Array<Character>) -> bencodeDataType {
        var list: [bencodeDataType] = []
        
        // consume first l
        _ = stream.popLast()
        
        while let next = stream.last, next != "e" {
            list.append(dechunk(stream: &stream))
        }
        
        _ = stream.popLast()
        return .list(list)
    }
}

//public func walk(_ value: bencodeDataType) {
//    switch value {
//
//    case let .string(s):
//        print("String:", s)
//
//    case let .int(i):
//        print("Int:", i)
//
//    case let .list(items):
//        print("List:")
//        for item in items {
//            walk(item)
//        }
//
//    case let .dict(dict):
//        print("Dict:")
//        for (key, val) in dict {
//            guard case let .string(keyString) = key else {
//                fatalError("bencode dictionaries must have string keys")
//            }
//            print("Key:", keyString)
//            walk(val)
//        }
//    }
//}
