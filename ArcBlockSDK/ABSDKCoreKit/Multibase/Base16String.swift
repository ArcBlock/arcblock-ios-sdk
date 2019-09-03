import Foundation

public extension Data {

    public init?(base16Encoded string: String) {
        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(u: UInt16) -> UInt8? {
            switch(u) {
            case 0x30 ... 0x39:
                return UInt8(u - 0x30)
            case 0x41 ... 0x46:
                return UInt8(u - 0x41 + 10)
            case 0x61 ... 0x66:
                return UInt8(u - 0x61 + 10)
            default:
                return nil
            }
        }

        self.init(capacity: string.utf16.count/2)
        var even = true
        var byte: UInt8 = 0
        for c in string.utf16 {
            guard let val = decodeNibble(u: c) else { return nil }
            if even {
                byte = val << 4
            } else {
                byte += val
                self.append(byte)
            }
            even = !even
        }
        guard even else { return nil }
    }

    public init?(base16Encoded data: Data) {
        guard let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        self.init(base16Encoded: string)
    }

    public func base16EncodedString() -> String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }

    public func base16EncodedData() -> Data {
        return self.base16EncodedString().data(using: .utf8)!
    }

}
