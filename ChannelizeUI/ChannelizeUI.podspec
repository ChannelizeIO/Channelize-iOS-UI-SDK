Pod::Spec.new do |spec|
  spec.name          = 'ChannelizeUI'
  spec.version       = '4.20.13'
  spec.license       = { :type => 'GPL', :file => 'LICENSE' }
  spec.homepage      = 'https://channelize.io/'
  spec.authors       = { "Channelize" => 'support@channelize.io' }
  spec.summary       = 'A Messaging UI SDK built for Channelize API SDK'
  spec.source        = { :git => 'https://github.com/ChannelizeIO/Channelize-iOS-UI-SDK.git', :tag => "#{spec.version}", :branch => "release/dark_light_theme"  }
  spec.swift_version = '5.0'
  spec.platform     = :ios, '11.0'
  spec.ios.deployment_target  = '11.0'
  spec.source_files = 'ChannelizeUI/ChannelizeUI/Sources/**/*.{h,m,swift}'
  spec.resources = ['ChannelizeUI/ChannelizeUI/Sources/Image_Resources/**/*.{jpeg,png}', 'ChannelizeUI/ChannelizeUI/Sources/ChannelizeActionIcons.xcassets', 'ChannelizeUI/ChannelizeUI/Sources/ChannelizeUIIcons.xcassets', 'ChannelizeUI/ChannelizeUI/Sources/Fonts/**/*.{ttf}']
  spec.info_plist = { 'CFBundleIdentifier' => 'com.channelize.ChannelizeUI' }
  spec.dependency "InputBarAccessoryView", "4.2.2"
  spec.dependency "Alamofire", "4.8.2"
  spec.dependency "ObjectMapper", "~> 3.5"
  spec.dependency "SDWebImageFLPlugin"
  spec.dependency "DifferenceKit"
  spec.dependency "ChannelizeAPI", ">= 4.20.11"
  spec.dependency "ReachabilitySwift"
  spec.dependency "MaterialComponents/ProgressView"
  spec.dependency "MaterialComponents/ActivityIndicator"
  spec.dependency "VirgilE3Kit"
end
