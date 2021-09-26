import Foundation

public enum BaseEncoding: UInt8 {
    case identity          = 000 // null
    case base1             = 049 // 1
    case base2             = 048 // 0
    case base8             = 055 // 7
    case base10            = 057 // 9
    case base16            = 102 // f
    case base16Upper       = 070 // F
    case base32            = 098 // b
    case base32Upper       = 066 // B
    case base32Pad         = 099 // c
    case base32PadUpper    = 067 // C
    case base32Hex         = 118 // v
    case base32HexUpper    = 089 // V
    case base32HexPad      = 116 // t
    case base32HexPadUpper = 084 // T
    case base58Flickr      = 090 // Z
    case base58BTC         = 122 // z
    case base64            = 109 // m
    case base64URL         = 117 // u
    case base64Pad         = 077 // M
    case base64URLPad      = 085 // U
}

public extension String {

    public var baseEncoding: BaseEncoding {
        let base = Array(self.utf8)[0]
        return BaseEncoding(rawValue: base)!
    }

}

public extension Data {

    public func multibaseEncodedString(inBase base: BaseEncoding) -> String {
        let byteString = [base.rawValue] + self
        let stringBaseEncoding = String(bytes: [base.rawValue], encoding: String.Encoding.utf8)!

        switch base {
        case .identity:
            return String(bytes: byteString, encoding: String.Encoding.utf8)!
        case .base16:
            return stringBaseEncoding + self.base16EncodedString().lowercased()
        case .base16Upper:
            return stringBaseEncoding + self.base16EncodedString().uppercased()
        case .base32Pad:
            return stringBaseEncoding + self.base32EncodedString().lowercased()
        case .base32PadUpper:
            return stringBaseEncoding + self.base32EncodedString().uppercased()
        case .base32HexPad:
            return stringBaseEncoding + self.base32HexEncodedString().lowercased()
        case .base32HexPadUpper:
            return stringBaseEncoding + self.base32HexEncodedString().uppercased()
        case .base58BTC:
            return stringBaseEncoding + self.base58EncodedString(alphabet: Base58String.btcAlphabet)
        case .base58Flickr:
            return stringBaseEncoding + self.base58EncodedString(alphabet: Base58String.flickrAlphabet)
        case .base64Pad:
            return stringBaseEncoding + self.base64EncodedString()
        case .base64URLPad:
            return stringBaseEncoding + self.base64URLPadEncodedString()
        default:
            fatalError("Unsuported base encoding \(base)")
        }
    }

    public init?(multibaseEncoded multibaseString: String) {
        let byteString = Data(multibaseString.utf8)
        guard byteString.count > 0,
            let base = BaseEncoding(rawValue: byteString[0]) else { return nil }
        guard byteString.count >= 2 else {
            return nil
        }
        let string = String(bytes: byteString[1...], encoding: String.Encoding.utf8)!

        switch base {
        case .identity:
            self = byteString[1...]
        case .base16, .base16Upper:
            guard let decoded = Data(base16Encoded: string) else {
                return nil
            }
            self = decoded
        case .base32Pad, .base32PadUpper:
            guard let decoded = Data(base32Encoded: string) else {
                return nil
            }
            self = decoded
        case .base32HexPad, .base32HexPadUpper:
            guard let decoded = Data(base32HexEncoded: string) else {
                return nil
            }
            self = decoded
        case .base58BTC:
            guard let decoded = Data(base58Encoded: string, alphabet: Base58String.btcAlphabet) else {
                return nil
            }
            self = decoded
        case .base58Flickr:
            guard let decoded = Data(base58Encoded: string, alphabet: Base58String.flickrAlphabet) else {
                return nil
            }
            self = decoded
        case .base64Pad:
            guard let decoded = Data(base64Encoded: string) else {
                return nil
            }
            self = decoded
        case .base64URLPad:
            guard let decoded = Data(base64URLPadEncoded: string) else {
                return nil
            }
            self = decoded
        default:
            return nil
        }
    }

}
