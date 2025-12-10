import Foundation
import torrent

let testBencodeString = "25:This is a bencode string!"
////let testDecodedString = try decode(data: testBencodeString)
//
//if case let .string(testDecodedString) = try decode(data: testBencodeString) {
//    print(testDecodedString)
//    print(type(of: testDecodedString))
//}
//
let testBencodeInt = "i45e"
//if case let .int(testDecodedInt) = try decode(data: testBencodeInt) {
//    print(testDecodedInt)
//    print(type(of: testDecodedInt))
//}

// TODO: Add dict to testBencodeList when dict parser ready
//let testBencodeList = "l6:Stringe"
//let testBencodeList = "l6:Stringi45el6:Nested4:Listi2eee"
let testBencodeList = "ll5:green4:eggs3:and3:hamel6:second4:list4:testee"
//if case let .list(testDecodedList) = try decode(data: testBencodeList) {
//    print(testDecodedList)
//    print(type(of: testDecodedList))
//    for item in testDecodedList {
//        print(item)
//    }
//}
//
let testBencodeDict = "d4:spam4:eggs5:soundi42e4:listli1ei2ei3eee"
////let testBencodeDict = "d4:spam4:eggse"
//if case let .dict(testDecodedDict) = try decode(data: testBencodeDict) {
//    print(testDecodedDict)
//    print(type(of: testDecodedDict))
//}

//let walkedString = try walker(bencodedObject: try decode(data: testBencodeString)!)
//let walkedInt = try walker(bencodedObject: try decode(data: testBencodeInt)!)
//let walkedList = try walker(bencodedObject: try decode(data: testBencodeList)!)
//let walkedDict = try walker(bencodedObject: try decode(data: testBencodeDict)!)

//print(walkedString)
//print(type(of: walkedString))
//print(walkedInt)
//print(type(of: walkedInt))
//print(walkedList)
//print(type(of: walkedList))
//print(walkedDict)
//print(type(of: walkedDict))

// MARK: - walk through walkedDict - modify to fit needs
//if let dict = walkedDict as? [String: Any] {
//    if let entry = dict["sound"] {
//        print(entry)
//        print(type(of: entry))
//    }
//}

// MARK: - walk through walkedList - modify to fit needs.
//if let array = walkedList as? [Any] {
//    for element in array{
//        switch element {
//        case let s as String:
//            print(s)
//            print(type(of: s))
//        case let i as Int:
//            print(i)
//            print(type(of: i))
//        case let l as [Any]:
//            print(l)
//            print(type(of: l))
//        case let d as [String: Any]:
//            print(d)
//            print(type(of: d))
//        default:
//            print("Error")
//        }
//    }
//}

// MARK: ASCII test implementation

//let testascii = "This is just some test. I'm curious about how it will come out."
//if let asciitest = try? toBytes(data: testascii) {
//  for item in asciitest { print(item, separator: " ", terminator: " ") }
//}
//
//let recursiveList = [[[[["deep", "primitive", "recursion"]]]]]
//
//if let recursiveBencode = try? encode(data: recursiveList) { print(recursiveBencode) }
//
//let testDict: [String: Any] = ["surface": "dictionary", "nested": ["dictionary": "here"]]
//guard let encodedDict = try? encode(data: testDict) else {
//  fatalError("I would be more surprised if this actually worked first try")
//}
//print(encodedDict)
//
//let url = URL(fileURLWithPath: "/Users/cloudy/Downloads/ubuntu-25.10-desktop-amd64.iso.torrent")
//let fileData = try Data(contentsOf: url)

//let testString = try fromBytes(data: fileData)
//
//print(testString)

if let torrent = Torrent(path: "/Users/cloudy/Downloads/ubuntu-25.10-desktop-amd64.iso.torrent") {
    print("✅ Torrent created")
    print(torrent.getValues())
} else {
    print("❌ Failed to create torrent")
}
