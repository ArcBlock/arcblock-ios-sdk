// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ArcBlockSDK",
    defaultLocalization: "en-US",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
    ],    
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
            from: "1.19.0"
            ),                   
        .package(
            url: "https://github.com/ashleymills/Reachability.swift.git", 
            exact: "5.1.0"
            ),
        // .package(
        //     url: "https://github.com/Quick/Nimble.git", 
        //     from: "1.0.0"
        //     ),            
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ArcBlockSDK",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "web3swift", package: "web3swift"),
                .product(name: "web3swift", package: "web3swift"),
                ],
            path: "ArcBlockSDK",
            linkerSettings: [
                .linkedFramework("UIKit", .when(platforms: [.iOS]))
                ]
            // sources: ["ArcBlockSDK"]
            ),
        // .testTarget(
        //     name: "ArcBlockSDKTests",
        //     dependencies: ["ArcBlockSDK"],
        //     path: "ArcBlockSDKTests"
        //     // sources: ["ArcBlockSDKTests"]
        //     ),
    ]
)


