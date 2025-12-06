//
//  main.swift
//  torrent
//
//  Created by Tyler Hall on 5/12/2025.
//

import Foundation
import torrent

let testBencodeString = "25:This is a bencode string!"
//let testDecodedString = try decode(data: testBencodeString)

if case let .string(testDecodedString) = try decode(data: testBencodeString) {
    print(testDecodedString)
    print(type(of: testDecodedString))
}

let testBencodeInt = "i45e"
if case let .int(testDecodedInt) = try decode(data: testBencodeInt) {
    print(testDecodedInt)
    print(type(of: testDecodedInt))
}

// TODO: Add dict to testBencodeList when dict parser ready
//let testBencodeList = "l6:Stringe"
let testBencodeList = "l6:Stringi45el6:Nested4:Listi2eee"
if case let .list(testDecodedList) = try decode(data: testBencodeList) {
    print(testDecodedList)
    print(type(of: testDecodedList))
    for item in testDecodedList {
        print(item)
    }
}

let testBencodeDict = "d4:spam4:eggs5:soundi42e4:listli1ei2ei3eee"
//let testBencodeDict = "d4:spam4:eggse"
if case let .dict(testDecodedDict) = try decode(data: testBencodeDict) {
    print(testDecodedDict)
    print(type(of: testDecodedDict))
}

let walkedString = try walker(bencodedObject: try decode(data: testBencodeString)!)
let walkedInt = try walker(bencodedObject: try decode(data: testBencodeInt)!)
let walkedList = try walker(bencodedObject: try decode(data: testBencodeList)!)
let walkedDict = try walker(bencodedObject: try decode(data: testBencodeDict)!)

print(walkedString)
print(type(of: walkedString))
print(walkedInt)
print(type(of: walkedInt))
print(walkedList)
print(type(of: walkedList))
print(walkedDict)
print(type(of: walkedDict))

// MARK: - walk through walkedList - modify to fit needs.
if let array = walkedList as? [Any] {
    for element in array{
        switch element {
        case let s as String:
            print(s)
        case let i as Int:
            print(i)
        case let l as [Any]:
            print(l)
        case let d as [String: Any]:
            print(d)
        default:
            print("Error")
        }
    }
}
            
