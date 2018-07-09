#
# Be sure to run `pod lib lint ABSDKCoreKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ArcBlockSDK'
  s.version          = '0.4.9'
  s.summary          = 'Used to integrate iOS apps with ArcBlock Platform.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/arcblock/arcblock-ios-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jonathanlu813' => 'jonathanlu813@gmail.com' }
  s.source           = { :git => 'https://github.com/ArcBlock/arcblock-ios-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.swift_version = '4.0'
  s.pod_target_xcconfig = {'DEFINES_MODULE' => 'YES'}

  s.subspec 'CoreKit' do |sc|
    sc.source_files = 'ABSDKCoreKit/**/*.{h,m,swift}'
    sc.dependency 'Apollo', '0.8.0'
    sc.dependency 'SQLite.swift', '0.11.5'
    sc.dependency 'ReachabilitySwift', '4.0.0'
  end

  s.subspec 'AccountKit' do |sa|
    sa.source_files = 'ABSDKAccountKit/**/*.{h,m}'
    sa.dependency 'ArcBlockSDK/CoreKit'
  end

  s.subspec 'MessagingKit' do |sm|
    sm.source_files = 'ABSDKMessagingKit/**/*.{h,m}'
    sm.dependency 'ArcBlockSDK/CoreKit'
  end

  s.subspec 'WalletKit' do |sw|
    sw.source_files = 'ABSDKWalletKit/**/*.{h,m}'
    sw.dependency 'ArcBlockSDK/CoreKit'
  end

end
