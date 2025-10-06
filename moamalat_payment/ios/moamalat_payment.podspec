#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint moamalat_payment.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'moamalat_payment'
  s.version          = '2.0.0'
  s.summary          = 'Comprehensive Flutter package for Moamalat payment gateway integration'
  s.description      = <<-DESC
Comprehensive Flutter package for Moamalat payment gateway integration with native Android SDK and WebView support, featuring intelligent auto-selection and Libya-focused currency handling.
                       DESC
  s.homepage         = 'https://github.com/HAMEDNGOMA/moamalatPayment'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'HAMEDNGOMA' => 'hamedngoma@example.com' }

  # Flutter plugin dependencies
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'PayButtonNumo'

  # Platform requirements
  s.platform = :ios, '11.0'
  s.ios.deployment_target = '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end