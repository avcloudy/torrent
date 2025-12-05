import Testing
@testable import torrent

//@Test func bencodeString(){
//    let bencodedString = "16:This is a string!4:eggs"
//    let tester = String(Bencode(data: bencodedString).decode())
//    #expect(tester == "This is a string!")
//}

@Test
func bencodeString() {
    let bencodedString = "17:This is a string!4:eggs"
    let decoded = Bencode(data: bencodedString).decode()
    
    guard case let .string(value) = decoded else {
        fatalError("Expected a string")
    }

    #expect(value == "This is a string!")
}

@Test
func bencodeString2() {
    let bencodedString = "16:This is a string!4:eggs"
    let decoded = Bencode(data: bencodedString).decode()
    
    guard case let .string(value) = decoded else {
        fatalError("Expected a string")
    }

    #expect(value == "This is a string")
}

@Test
func bencodeStringManual() {
    let bencodedString = "16:This is a string!4:eggs"
    let decoded = Bencode(data: bencodedString).decode()
    
    guard case let .string(value) = decoded else {
        fatalError("Expected a string")
    }

    #expect("This is a string!" == "This is a string!")
}
