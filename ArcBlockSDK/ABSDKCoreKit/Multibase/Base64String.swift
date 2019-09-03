import Foundation

public extension Data {

    public init?(base64URLPadEncoded string: String) {
        var base64 = string
        base64 = base64.replacingOccurrences(of: "-", with: "+")
        base64 = base64.replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 = base64.appending("=")
        }
        self.init(base64Encoded: base64)
    }

    public init?(base64URLPadEncoded data: Data) {
        guard let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        self.init(base64URLPadEncoded: string)
    }

    public func base64URLPadEncodedString() -> String {
        var result = self.base64EncodedString()
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")
        return result
    }

    public func base64URLPadEncodedData() -> Data {
        return self.base64URLPadEncodedString().data(using: .utf8)!
    }

}
