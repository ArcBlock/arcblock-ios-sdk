// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ArcBlockSDK",
    defaultLocalization: "en-US",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ArcBlockSDK",
            targets: ["ArcBlockSDK"]),
    ],
     dependencies: [
        .package(url: "https://github.com/web3swift-team/web3swift",
                 exact: "3.1.2"
         ), 
        .package(url: "https://github.com/ArcBlock/apollo-ios.git", branch: "master"),
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            "1.19.0" ..< "2.0.0"
            ),            
        .package(
            url: "https://github.com/attaswift/BigInt.git",
            "5.3.0" ..< "5.4.0"
            ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            "1.5.1" ..< "1.6.0"
            ),            
        .package(
            url: "https://github.com/ashleymills/Reachability.swift.git", 
            exact: "5.1.0"
            ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ArcBlockSDK",
            path: "ArcBlockSDK"
            // sources: ["ArcBlockSDK"]
            ),
        .testTarget(
            name: "ArcBlockSDKTests",
            dependencies: ["ArcBlockSDK"],
            path: "ArcBlockSDKTests"
            // sources: ["ArcBlockSDKTests"]
            ),
    ]
)


