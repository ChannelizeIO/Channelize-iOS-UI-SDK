Pod::Spec.new do |spec|
  spec.name          = 'ChannelizeUI'
  spec.version       = '4.20.6'
  spec.license       = { :type => 'GPL', :file => 'LICENSE' }
  spec.homepage      = 'https://channelize.io/'
  spec.authors       = { "Channelize" => 'support@channelize.io' }
  spec.summary       = 'A Messaging UI SDK built for Channelize API SDK'
  spec.source        = { :git => 'https://github.com/ChannelizeIO/Channelize-iOS-UI-SDK.git', :tag => "#{spec.version}", :branch => "master"  }
  spec.swift_version = '4.2'
  spec.platform     = :ios, '11.0'
  spec.ios.deployment_target  = '11.0'
  spec.source_files = 'ChannelizeUI/ChannelizeUI/Sources/**/*.swift'
  spec.dependency "InputBarAccessoryView", "4.2.2"
  spec.dependency "Alamofire", "4.8.2"
  spec.dependency "AlamofireObjectMapper", "5.2.0"
  spec.dependency "SDWebImageFLPlugin"
  spec.dependency "MaterialComponents"
  spec.dependency "DifferenceKit"
  spec.dependency "ChannelizeAPI", ">= 4.20.6"
end
