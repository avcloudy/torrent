import Foundation

public enum bencode: Hashable {
  case string(String)
  case int(Int)
  indirect case list([bencode])
  indirect case dict([bencode: bencode])
}
