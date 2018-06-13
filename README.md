# ArcBlock iOS SDK

[![Build Status](https://travis-ci.com/ArcBlock/arcblock-ios-sdk.svg?token=qqAgewfANpc6odwwyKWa&branch=master)](https://travis-ci.com/ArcBlock/arcblock-ios-sdk)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
<!-- [![Version](https://img.shields.io/cocoapods/v/ArcBlockSDK.svg?style=flat)](http://cocoapods.org/pods/ArcBlockSDK)
[![License](https://img.shields.io/cocoapods/l/ArcBlockSDK.svg?style=flat)](http://cocoapods.org/pods/ArcBlockSDK)
[![Platform](https://img.shields.io/cocoapods/p/ArcBlockSDK.svg?style=flat)](http://cocoapods.org/pods/ArcBlockSDK) -->

Welcome to ArcBlock iOS SDK! This is what you need to integrate your iOS apps with ArcBlock Platform.

## Requirements
The ArcBlock iOS SDK is compatible with apps supporting iOS 9 and above and requires Xcode 9 to build from source.

## Installation

### CocoaPods
ArcBlockSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ArcBlockSDK'
```

This will install all [kits](#kits). Or you can install the specific kit you need, for example:

```ruby
pod 'ArcBlockSDK/AccountKit'
```

### Carthage

To integrate ArcBlockSDK into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "ArcBlock/arcblock-ios-sdk"
```

Run `carthage` to build the framework and drag the built frameworks into your Xcode project.

## Kits

ArcBlock iOS SDK includes 4 kits, they are **ABSDKCoreKit**, **ABSDKAccountKit**, **ABSDKMessagingKit** and **ABSDKWalletKit**.

### ABSDKCoreKit
ABSDKCoreKit is the core module of the ArcBlock iOS SDK. It handles data persistence, networking and UI-data binding for higher level application logics. Other SDK components such as ABSDKAccountKit are based on ABSDKCoreKit. Altogether they serve as the cornerstones for all ArcBlock iOS apps, and can be used by many other developers to build apps on ArcBlock platform.

### ABSDKAccountKit

TBD

### ABSDKMessagingKit

TBD

### ABSDKWalletKit

TBD

## License

ArcBlockSDK is available under the MIT license. See the LICENSE file for more info.
