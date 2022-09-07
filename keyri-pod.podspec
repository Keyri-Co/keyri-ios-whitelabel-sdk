#
# Be sure to run `pod lib lint keyri-pod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'keyri-pod'
  s.version          = '1.7.2'
  s.summary          = 'QR/Passwordless auth with in built risk analytics'

  s.homepage         = 'https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'amalladi94' => 'aditya@keyri.co' }
  s.source           = { :git => 'https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'
  s.swift_versions = '5.3'

  s.source_files = 'keyri-pod/Classes/**/*'
  
  s.resource_bundles = {
      'keyri-pod' => ['keyri-pod/Assets/**/*']
  }

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
