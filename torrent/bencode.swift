import Foundation

/// An ASCII string encoded with 'Bencode'
/// Strings are declared with an integer, length of string then the string literal i:str, for example 5:tests
/// Integers are declared with the character i, the integer, then the integer, and ending with i,
/// i#e, for example i3e. Leading zeroes invalid, no i03e.
/// Lists are declared with the character l, with : as a delimited, and may contain any Bencode
/// type. For instance l4:spam:4:eggse or ll4:spam:4:eggsel5:green:4:eggs:3:hame
/// Dictionaries are declared with the character d, the key and then the value, and end with e.
/// The key must be a string, and the value can be any Bencoded object,
/// For example d4:spam:4:eggse
struct Bencode {
    let data: String
    
    enum bencodeDataType: Hashable {
        case string(String)
        case int(Int)
        indirect case dict(Dictionary<bencodeDataType, bencodeDataType>)
        indirect case list(Array<bencodeDataType>)
    }
    
    /// Translate a Bencode object into native data structures
    /// - Parameter data: ASCII Bencode string
    func decode(data: String) -> bencodeDataType {
        var stream = Array(data)
        stream.reverse()
        let root = dechunk(stream: stream)
        return root
    }
    
    /// Recursively interpret Bencode objects
    /// - Parameter data: An array of characters, reversed to optimise popLast()
    /// - Returns: A complete bencodeDataType -> each decode function returns the first bencodeDataType it finds
    private func dechunk(stream data: Array<Character>) -> bencodeDataType {
        let isNumberRange: ClosedRange<Character> = "0"..."9"
        var stream = data
        // TODO: Check if I can change type of enum on later assignment
        var output: bencodeDataType?
        
        while !stream.isEmpty {
            var flag = stream.popLast()
            // can force unwrap flag, because stream is not empty
            switch flag! {
            case isNumberRange:
                output = decodeString(stream: &stream, char: flag!)
            case "i":
                output = decodeInt(stream: &stream)
            case "d":
                output = decodeDict(stream: &stream)
            case "l":
                output = decodeList(stream: &stream)
            default:
                print("This is not a valid Bencode flag.\n")
            }
        }
        return output ?? .string("")
    }
    
    func test(stream data: Array<Character>) -> bencodeDataType {
        let isNumberRange: ClosedRange<Character> = "0"..."9"
        var stream = data
        var output: Array<bencodeDataType> = []
        stream.reverse()
        // going to create array from string, and iterate manually over array
        // going to create 'chunks' where get complete objects
        // for strings, if get int '11' pop slice [k:k+11+[length of int]+1]
        // and feed into decodeString
        while !stream.isEmpty {
            var flag = stream.popLast()
            // force unwrap because stream can't be empty
            switch flag! {
            case "i":
                var item = stream.popLast()
                var integerString: String = ""
                while item != "e" {
                    integerString.append(item!)
                }
                output.append(decodeInt(string: integerString))
            case "l":
                var nextCharacter = stream.popLast()
                var list: Array<bencodeDataType> = []
                while nextCharacter != "e" {
                    list.append(decode(data: stream))
                    while nextCharacter != ":" {
                        
                        list.append(item!)
                        item = stream.popLast()
                    }
                }
                output.append(listString)
            case "d":
            }
        }
        
    }
    
    private func decodeString(stream: inout Array<Character>, char firstCharofLength: Character) -> bencodeDataType {
        var stringLengthIntString = String(firstCharofLength)
        var returnString: String = ""
        while !stream.isEmpty {
            var nextCharacter = stream.popLast()
            while nextCharacter != ":" {
                stringLengthIntString.append(nextCharacter!)
                nextCharacter = stream.popLast()
            }
            let stringLength = Int(stringLengthIntString) ?? 1
            for _ in 0...stringLength {
                returnString.append(stream.popLast()!)
            }
        }
        return .string(returnString)
    }
    private func decodeInt(stream: inout Array<Character>) -> bencodeDataType {
        var integerString: String = ""
        while !stream.isEmpty {
            var nextCharacter = stream.popLast()
            while nextCharacter != "e" {
                integerString.append(nextCharacter!)
                nextCharacter = stream.popLast()
            }
        }
        return .int(Int(integerString)!)
    }
    private func decodeDict(stream data: inout Array<Character>) -> bencodeDataType {
        return .dict([:])
    }
    private func decodeList(stream data: inout Array<Character>) -> bencodeDataType {
        return .list([])
    }
}
