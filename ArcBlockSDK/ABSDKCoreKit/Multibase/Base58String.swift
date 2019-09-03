import Foundation
import BigInt

public enum Base58String {
    public static let btcAlphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    public static let flickrAlphabet = "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ"
}

public extension Data {

    public init?(base58Encoded string: String, alphabet: String = Base58String.btcAlphabet) {
        guard let data = Base58.decode(string, alphabet) else {
            return nil
        }
        self = data
    }

    public init?(base58Encoded data: Data, alphabet: String = Base58String.btcAlphabet) {
        guard let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        self.init(base58Encoded: string, alphabet: alphabet)
    }

    public func base58EncodedString(alphabet: String = Base58String.btcAlphabet) -> String {
        return Base58.encode(self, alphabet)
    }

    public func base58EncodedData() -> Data {
        return self.base58EncodedString().data(using: .utf8)!
    }

}
