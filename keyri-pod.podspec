Pod::Spec.new do |spec|
  spec.name             = 'keyri-pod'
  spec.version          = '4.3.3'
  spec.summary          = 'QR/Passwordless auth with in built risk analytics'

  spec.homepage         = 'https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { 'AndrewKuliahin96' => 'kulagin.andrew38@gmail.com' }
  spec.source           = { :git => 'https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk.git', :tag => s.version.to_s }
  spec.social_media_url = 'https://twitter.com/keyriauth'

  spec.ios.deployment_target = '14.0'
  spec.swift_versions = '5.3'

  spec.vendored_frameworks = 'keyri-pod/Framework/Keyri.xcframework'
end
