#
# Be sure to run `pod lib lint ABSDKCoreKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ABSDKCoreKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ABSDKCoreKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/jonathanlu813/ABSDKCoreKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jonathanlu813' => 'jonathanlu813@gmail.com' }
  s.source           = { :git => 'https://github.com/jonathanlu813/ABSDKCoreKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'ABSDKCoreKit/ABSDKCoreKit/**/*'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'ABSDKCoreKit/ABSDKCoreKitTests/*.{h,m}'
    # test_spec.dependency 'OCMock' # This dependency will only be linked with your tests.
  end

  # s.resource_bundles = {
  #   'ABSDKCoreKit' => ['ABSDKCoreKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency "SocketRocket"
  s.dependency "YapDatabase"
  s.dependency "AFNetworking"
  s.dependency "KVOController"
  s.dependency "Reachability"
  s.dependency "SDWebImage"
end
