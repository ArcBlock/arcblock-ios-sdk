import class Foundation.Bundle

extension Foundation.Bundle {
    static let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("ArcBlockSDK_ArcBlockSDK.bundle").path
        let buildPath = "/Users/zy/Desktop/ArcBlock/Code/arcblock-ios-sdk/.build/arm64-apple-macosx/debug/ArcBlockSDK_ArcBlockSDK.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}