# ArcBlock iOS SDK

[![Build Status](https://travis-ci.com/ArcBlock/arcblock-ios-sdk.svg?token=qqAgewfANpc6odwwyKWa&branch=master)](https://travis-ci.com/ArcBlock/arcblock-ios-sdk)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
<!-- [![Version](https://img.shields.io/cocoapods/v/ArcBlockSDK.svg?style=flat)](http://cocoapods.org/pods/ArcBlockSDK)
[![License](https://img.shields.io/cocoapods/l/ArcBlockSDK.svg?style=flat)](http://cocoapods.org/pods/ArcBlockSDK)
[![Platform](https://img.shields.io/cocoapods/p/ArcBlockSDK.svg?style=flat)](http://cocoapods.org/pods/ArcBlockSDK) -->

Welcome to ArcBlock iOS SDK! This is what you need to integrate your iOS apps with ArcBlock Platform. The ArcBlock iOS SDK is based on the Apollo project found [here](https://github.com/apollographql/apollo-ios).

## Requirements
The ArcBlock iOS SDK is compatible with apps supporting iOS 9 and above and requires Xcode 9 to build from source.

## Installation

### CocoaPods
ArcBlockSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following lines to your Podfile:

```ruby
pod 'ArcBlockSDK', :git => 'https://github.com/ArcBlock/arcblock-ios-sdk.git'
pod 'Apollo', :git => 'https://github.com/ArcBlock/apollo-ios.git'
```

### Carthage

To integrate ArcBlockSDK into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "ArcBlock/arcblock-ios-sdk"
```

Run `carthage` to build the framework and drag the built frameworks into your Xcode project.

### XCode File Templates

ArcBlockSDK provides some XCode file templates for you to get started more quickly. To install them, run the following command:

``` bash
wget http://ios-docs.arcblock.io/Templates.tar.gz; \
tar -xvf Templates.tar.gz --strip-components=1 --directory ~/Library/Developer/Xcode/Templates/File\ Templates/; \
rm Templates.tar.gz
```

## Usage

For a quick start, please check our [Quick Start Guide](https://github.com/ArcBlock/arcblock-ios-sdk/blob/master/QuickStart.md). It will walk you through the easiest way to build an app that connects to the  ArcBlock platform.

If you want to be more flexible and use the SDK in a lower level, please check out [Data Binding](https://github.com/ArcBlock/arcblock-ios-sdk/blob/master/DataBinding.md) and [Client](https://github.com/ArcBlock/arcblock-ios-sdk/blob/master/Client.md) documentation.

## FAQ


## License

ArcBlockSDK is available under the MIT license. See the LICENSE file for more info.
