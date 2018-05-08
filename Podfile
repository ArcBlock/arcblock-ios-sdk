source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'ABSDKCoreKit' do
    pod "SocketRocket"
    pod "YapDatabase"
    pod "AFNetworking"
    pod "KVOController"
    pod "Reachability"
    pod "SDWebImage"
end

target 'ABSDKCoreKitTests' do
    pod "Quick"
    pod "Nimble"
end

target 'ABSDKAccountKitTests' do
    pod "Quick"
    pod "Nimble"
end

target 'ABSDKMessagingKitTests' do
    pod "Quick"
    pod "Nimble"
end

target 'ABSDKWalletKitTests' do
    pod "Quick"
    pod "Nimble"
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = "4.0"
        end
    end
end
