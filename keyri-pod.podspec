Pod::Spec.new do |s|
  s.name             = 'keyri-pod'
  s.version          = '4.3.0'
  s.summary          = 'QR/Passwordless auth with in built risk analytics'
  
  s.homepage         = 'https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AndrewKuliahin96' => 'kulagin.andrew38@gmail.com' }
  s.source           = { :git => 'https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/keyriauth'
  
  s.ios.deployment_target = '14.0'
  s.swift_versions = '5.3'
  
  s.vendored_frameworks = 'keyri-pod/Framework/Keyri.xcframework'
end
