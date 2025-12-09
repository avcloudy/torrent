import Foundation

enum byteError: Error {
  case nonASCIIcharacters(string: String)
  case notStringEncodable(data: Data)
}

public func toBytes(data: String) throws -> Data {
  guard let byteStream = data.data(using: .ascii) else {
    throw byteError.nonASCIIcharacters(string: data)
  }
  return byteStream
}

public func fromBytes(data: Data) throws -> String {
  guard let string = String(data: data, encoding: .ascii) else {
    throw byteError.notStringEncodable(data: data)
  }
  return string
}
