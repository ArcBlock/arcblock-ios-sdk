import class Foundation.Bundle

extension Foundation.Bundle {
    static let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("Web3swift_web3swift.bundle").path
        let buildPath = "/Users/zy/Desktop/ArcBlock/Code/arcblock-ios-sdk/.build/arm64-apple-macosx/debug/Web3swift_web3swift.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}