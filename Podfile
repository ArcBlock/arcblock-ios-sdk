target 'ArcBlockSDK' do
    use_frameworks!

    pod 'Apollo', :git => 'https://github.com/ArcBlock/apollo-ios.git'
    pod 'ReachabilitySwift'
    pod 'SwiftProtobuf', '~> 1.0'
    pod 'web3swift', :git => 'https://github.com/ArcBlock/web3swift.git'
end

target 'ArcBlockSDKTests' do
    use_frameworks!
    inherit! :search_paths

    pod 'Nimble'
    pod 'Quick'
    pod 'Apollo', :git => 'https://github.com/ArcBlock/apollo-ios.git'
    pod 'ReachabilitySwift'
    pod 'SwiftProtobuf', '~> 1.0'
    pod 'web3swift', :git => 'https://github.com/ArcBlock/web3swift.git'
end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end
