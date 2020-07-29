Pod::Spec.new do |spec|
  spec.name          = 'ChannelizeUI'
  spec.version       = '4.10.40'
  spec.license       = { :type => 'GPL', :file => 'LICENSE' }
  spec.homepage      = 'https://channelize.io/'
  spec.authors       = { "Channelize" => 'support@channelize.io' }
  spec.summary       = 'A Messaging UI SDK built for Channelize API SDK'
  spec.source        = { :git => 'https://github.com/ChannelizeIO/Channelize-iOS-UI-SDK.git', :tag => "#{spec.version}", :branch => "release/dark_light_theme"  }
  spec.swift_version = '4.2'
  spec.platform     = :ios, '11.0'
  spec.ios.deployment_target  = '11.0'
  spec.source_files = 'ChannelizeUI/ChannelizeUI/Sources/**/*.{h,m,swift}'
  spec.resources = 'ChannelizeUI/ChannelizeUI/Sources/ChannelizeUI.bundle'
  spec.resource_bundles = { "ChannelizeUI" => ['ChannelizeUI/ChannelizeUI/Sources/Image_Sources/ChannelizeActionIcons.xcassets','ChannelizeUI/ChannelizeUI/Sources/Image_Sources/ChannelizeUIIcons.xcassets'] }
  spec.dependency "InputBarAccessoryView", "4.2.2"
  spec.dependency "Alamofire", "4.8.2"
  spec.dependency "ObjectMapper", "~> 3.5"
  spec.dependency "SDWebImageFLPlugin"
  spec.dependency "DifferenceKit"
  spec.dependency "ChannelizeAPI", ">= 4.20.10"
  spec.dependency "ReachabilitySwift"
  spec.dependency "MaterialComponents/ProgressView"
  spec.dependency "MaterialComponents/ActivityIndicator"
  spec.dependency "VirgilE3Kit"
end
