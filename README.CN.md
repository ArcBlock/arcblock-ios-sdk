# ArcBlock iOS SDK

[![Build Status](https://travis-ci.com/ArcBlock/arcblock-ios-sdk.svg?token=qqAgewfANpc6odwwyKWa&branch=master)](https://travis-ci.com/ArcBlock/arcblock-ios-sdk)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
<!-- [![Version](https://img.shields.io/cocoapods/v/ArcBlockSDK.svg?style=flat)](http://cocoapods.org/pods/ArcBlockSDK)
[![License](https://img.shields.io/cocoapods/l/ArcBlockSDK.svg?style=flat)](http://cocoapods.org/pods/ArcBlockSDK)
[![Platform](https://img.shields.io/cocoapods/p/ArcBlockSDK.svg?style=flat)](http://cocoapods.org/pods/ArcBlockSDK) -->

欢迎使用ArcBlock iOS SDK。它将会帮助你轻松顺利地将你的iOS应用接入ArcBlock平台。此SDK基于[Apollo](https://github.com/apollographql/apollo-ios)项目开发。

## 开发环境要求
* iOS 11或以上版本
* XCode 9或以上版本

## 安装

### CocoaPods
您可以通过[CocoaPods](http://cocoapods.org)安装ArcBlock iOS SDK，添加以下代码到您的`Podfile`：

```ruby
pod 'ArcBlockSDK', :git => 'https://github.com/ArcBlock/arcblock-ios-sdk.git'
pod 'Apollo', :git => 'https://github.com/ArcBlock/apollo-ios.git'
```

再运行`pod install`即可。

### Carthage

您也可以通过[Carthage](https://github.com/Carthage/Carthage)进行安装, 添加以下代码到`Cartfile`：

```ogdl
github "ArcBlock/arcblock-ios-sdk"
```

运行`carthage`以构建`.framework`文件，再将构建好的`.framework`文件拖拽到XCode项目中即可。

### XCode文件模板(可选)

ArcBlockSDK还提供了一系列Xcode文件模板。您可以使用它们来快速创建一些可运行的代码。安装这些模板只需要运行以下命令即可：

``` bash
wget http://ios-docs.arcblock.io/Templates.tar.gz; \
tar -xvf Templates.tar.gz --strip-components=1 --directory ~/Library/Developer/Xcode/Templates/File\ Templates/; \
rm Templates.tar.gz
```

## 使用说明

如果您想快速入门，请阅读我们的[快速入门文档](https://github.com/ArcBlock/arcblock-ios-sdk/blob/master/QuickStart.CN.md)。这篇文档将会为您介绍最简单的连接到ArcBlock平台的方法。

如果您希望更灵活地使用我们的SDK，我们也准备了一些底层部件的相关使用说明。您可以阅读[数据绑定](https://github.com/ArcBlock/arcblock-ios-sdk/blob/master/DataBinding.CN.md), [客户端](https://github.com/ArcBlock/arcblock-ios-sdk/blob/master/Client.CN.md)文档查看相关使用说明。另外也可以查看我们的[类参考](http://ios-docs.arcblock.io/)

## 常见问题

### Q：我可以用这个SDK做什么？

此SDK将帮助您接入ArcBlck的OCAP服务。您可以在OCAP服务的[文档](https://ocap.arcblock.io/docs)中查看它提供的功能和接口，并可以在[OCAP Playground](https://ocap.arcblock.io/docs)中探索和调试。

### Q：我必须在OCAP Playground中编写GraphQL语句吗？

OCAP service提供基于GraphQL接口，所以您需要编写GraphQL语句来和OCAP service通信。您可以使用任何一个编辑器来编写，但OCAP Playground提供了一些辅助功能来提高您的编写效率，减少错误。此外，您需要在Playbook中生成项目所需的Swift代码，而Playground中的语句可以非常轻松地被转换到Playbook中。

### Q：我必须要在Playbook中生成Swift代码吗？

是的，生成出的Swift代码是您的GraphQL语句的包装类。使用这些包装类可以确保在运行时的类型安全。此设计沿用自此SDK的基础[Apollo]((https://github.com/apollographql/apollo-ios))项目。与Apollo的设计不同之处在于，您不需要自己在本地运行生成代码的命令，因为这个步骤已经被整合到Playbook中了。当您在Playbook中整理好需要用的语句之后，直接可以在其中生成Swift代码。

### Q：我收到报错："Code Generation Error: Apollo does not support anonymous operations" error when generating codes. 这是为什么？

这表示您需要给您的语句起一个名字。例如，以下是一个匿名的语句：
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
而以下是一个命名的语句：
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

我们要求所有语句都是命名语句，否则无法生成Swift代码。

### Q：我必须安装Xcode文件模板吗？

不，这一步是可选的。文件模板可以让您更快地创建一个ViewController或View，并让他们和我们的SDK一起工作。这些模板都是基于一些ViewController或View的基类的，如ABSDKTableViewController，您可以不使用模板而是手动创建一个子类，以达到同样的效果。

### Q：我不想继承那些UI基类，他们耦合度太高太不灵活了，我想自己写，需要怎么做？

完全没有问题。那些UI基类是为了让大家快速入门而设计的，如果您已经有了一定的了解，您可以自己设计实现UI，而只使用SDK提供的部件来处理数据，详情请参考[数据绑定](https://github.com/ArcBlock/arcblock-ios-sdk/blob/master/DataBinding.CN.md)相关文档。

### Q：SDK支持什么类型的GraphQL操作？

目前，我们支持查询和订阅，更改操作将在稍后支持。详情请参考[OCAP service文档](https://ocap.arcblock.io/docs)。

## License

ArcBlockSDK在MIT许可下可用。有关详细信息，请参阅LICENSE文件。
