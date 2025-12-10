import Foundation

public enum bencode: Hashable {
    case string(Data)
    case int(Int)
    indirect case list([bencode])
    indirect case dict([bencode: bencode])
}
