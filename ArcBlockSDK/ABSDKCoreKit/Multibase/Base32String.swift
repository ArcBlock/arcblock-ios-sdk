import Foundation

public extension Data {

    public init?(base32Encoded string: String) {
        guard let data = base32DecodeToData(string) else {
            return nil
        }
        self = data
    }

    public init?(base32Encoded data: Data) {
        guard let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        self.init(base32Encoded: string)
    }

    public func base32EncodedString() -> String {
        return base32Encode(self)
    }

    public func base32EncodedData() -> Data {
        return self.base32EncodedString().data(using: .utf8)!
    }

}

public extension Data {

    public init?(base32HexEncoded string: String) {
        guard let data = base32HexDecodeToData(string) else {
            return nil
        }
        self = data
    }

    public init?(base32HexEncoded data: Data) {
        guard let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        self.init(base32HexEncoded: string)
    }

    public func base32HexEncodedString() -> String {
        return base32HexEncode(self)
    }

    public func base32HexEncodedData() -> Data {
        return self.base32HexEncodedString().data(using: .utf8)!
    }

}
