#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ffi_mina_signer.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ffi_mina_signer'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter Plugin To Operate Key Pairs Of Mina Protocol, With C Code Support'
  s.description      = <<-DESC
A Flutter Plugin To Operate Key Pairs Of Mina Protocol, With C Code Support
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
