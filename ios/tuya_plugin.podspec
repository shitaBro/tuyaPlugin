#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tuya_plugin.podspec` to validate before publishing.
#

Pod::Spec.new do |s|
  s.name             = 'tuya_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin for tuya iot'
  s.description      = <<-DESC
A new Flutter plugin for tuya iot
                       DESC
  s.homepage         = 'https://github.com/JarvisHot/tuyaPlugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'jarvis' => 'objectclass@163.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'TuyaSmartHomeKit'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
