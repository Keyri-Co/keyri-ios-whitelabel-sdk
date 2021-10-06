#
# Be sure to run `pod lib lint keyri-pod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'keyri-pod'
  s.version          = '0.1.3'
  s.summary          = 'Library for autorization'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/anovoselskyi/keyri-pod'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'anovoselskyi' => 'anovoselskyi@gmail.com' }
  s.source           = { :git => 'https://github.com/anovoselskyi/keyri-pod.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_versions = '5.3'

  s.source_files = 'keyri-pod/Classes/**/*'
  
  # s.resource_bundles = {
  #   'keyri-pod' => ['keyri-pod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.dependency 'Sodium-Fork', '~> 0.8.2'
  s.dependency 'KeychainAccess', '~> 4.2.2'
  s.dependency 'Socket.IO-Client-Swift', '~> 16.0.1'
  s.dependency 'QRCodeReader.swift', '10.1.0'

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
