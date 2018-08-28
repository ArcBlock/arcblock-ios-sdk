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

### XCode File Templates(Optional)

ArcBlockSDK provides some XCode file templates for you to get started more quickly. To install them, run the following command:

``` bash
wget http://ios-docs.arcblock.io/Templates.tar.gz; \
tar -xvf Templates.tar.gz --strip-components=1 --directory ~/Library/Developer/Xcode/Templates/File\ Templates/; \
rm Templates.tar.gz
```

## Usage

For a quick start, please check our [Quick Start Guide](https://github.com/ArcBlock/arcblock-ios-sdk/blob/master/QuickStart.md). It will walk you through the easiest way to build an app that connects to the  ArcBlock platform.

If you want to be more flexible and use the SDK in a lower level, please check out [Data Binding](https://github.com/ArcBlock/arcblock-ios-sdk/blob/master/DataBinding.md), [Client](https://github.com/ArcBlock/arcblock-ios-sdk/blob/master/Client.md) and the [Class Reference](http://ios-docs.arcblock.io/)

## FAQ

### Q: What kind of things I can do with this SDK?

This SDK helps you connect to the ArcBlock OCAP service, and the OCAP service capabilities can be found in its [documentation](https://ocap.arcblock.io/docs).

### Q: Do I have to write GraphQL queries in OCAP Playground?

You need to write GraphQL queries to communicate with OCAP service. You can write the queries in your text editor, but it's just easier to do so in the Playground. Besides, you'll need to generate Swift codes for your queries in the Playbook, and it's easier to convert queries in the Playground to a playbook.

### Q: Do I have to generate Swift codes in Playbook?

Yes. The generated codes are Swift wrappers for your queries, which help enforce type safety. It's required by [Apollo]((https://github.com/apollographql/apollo-ios)) which is the base of this SDK. But instead of having to run the codegen commands on your own(the Apollo way), the process is now integrated into the playbook, which is more natural.

### Q: I got "Code Generation Error: Apollo does not support anonymous operations" error when generating codes. What's wrong?

This means that you need to give names to your queries. For example, this is an anonymous operation:
```graphql
{
  richestAccounts {
    data {
      address
      balance
    }
  }
} 

```
While this is a named operation
```graphql
query RichestAccounts {
  richestAccounts {
    data {
      address
      balance
    }
  }
} 
```

We need every operation to be named to generate Swift codes.

### Q: Do I have to install the file templates?

No, it's optional. The file templates are for you to create ViewController and View faster. The base classes the templates are using, ABSDKTableViewController for example, can be inherited without using the file templates.

### Q: I don't want to inherit the UI classes provided by the SDK, rather I would like to write my own UI, what should I do?

That's totally fine. You can use the SDK just on the data level by using the ABSDKDataSource. You can find more detail [here](https://github.com/ArcBlock/arcblock-ios-sdk/blob/master/DataBinding.md).

### Q: What kind of operations are supported?

Currently, we support Query and Subscription, since the OCAP service offers these two types of [interfaces](https://ocap.arcblock.io/docs). Mutation will be supported shortly.

## License

ArcBlockSDK is available under the MIT license. See the LICENSE file for more info.
