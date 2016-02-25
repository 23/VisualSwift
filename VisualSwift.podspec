#
# Be sure to run `pod lib lint VisualSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "VisualSwift"
  s.version          = "0.1.1"
  s.summary          = "Swift library for interfacing with the 23 Video API"
  s.description      = <<-DESC
                       Swift library for interfacing with the 23 Video API.
                       Provides methods for anonymous or authenticated communication with endpoints.
                       DESC

  s.homepage         = "https://github.com/23/VisualSwift"
  s.license          = 'MIT'
  s.author           = { "Kalle Kabell" => "kkabell@gmail.com" }
  s.source           = { :git => "https://github.com/23/VisualSwift.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/23video'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'VisualSwift' => ['Pod/Assets/*.png']
  }

  s.dependency 'Alamofire', '~> 3.0'
  s.dependency 'IDZSwiftCommonCrypto', '~> 0.6.8'
end
