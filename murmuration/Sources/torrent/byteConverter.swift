import Foundation

enum byteError: Error {
    case nonASCIIcharacters(string: String)
    case notStringEncodable(data: Data)
    case stringDecodingFailed(data: Data)
}

public func toBytes(data: String) throws -> Data {
    guard let byteStream = data.data(using: .ascii) else {
        throw byteError.nonASCIIcharacters(string: data)
    }
    return byteStream
}

//public func fromBytes(data: Data) throws -> String {
//  guard let string = String(data: data, encoding: .ascii) else {
//    throw byteError.notStringEncodable(data: data)
//  }
//  return string
//}

public func fromBytes(data: Data) throws -> String {
    guard let string = String(data: data, encoding: .utf8) else {
        throw byteError.stringDecodingFailed(data: data)
    }
    return string
}
