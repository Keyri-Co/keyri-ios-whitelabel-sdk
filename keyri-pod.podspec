Pod::Spec.new do |spec|
  spec.name             = 'keyri-pod'
  spec.version          = '4.3.4'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage         = 'https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk'
  spec.authors          = { 'AndrewKuliahin96' => 'kulagin.andrew38@gmail.com' }
  spec.source           = { :git => 'https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk.git', :tag => spec.version.to_s }
  spec.summary          = 'QR/Passwordless auth with in built risk analytics'

  spec.ios.deployment_target = '14.0'
  spec.swift_version = '5.3'

  spec.vendored_frameworks = 'keyri-pod/Framework/Keyri.xcframework'
end
