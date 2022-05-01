
Pod::Spec.new do |s|
  s.name              = 'Rigi'
  s.version           = '1.0.0'
  s.summary           = 'Makes Rigi previews for your iOS project.'
  s.homepage          = 'https://rigi.io'
  s.author            = { 'Name' => 'dimitri@rigi.io' }
  s.license           = { :type => 'Copyright', :text => 'Copyright 2022 Rigi.io'}

  #s.source            = { :git => 'https://github.com/Dimi70/rigi-ios-sdk/1.0.0.zip', :tag => s.version.to_s }
  s.source            = { :git => 'https://github.com/Dimi70/rigi-ios-sdk.git', :tag => s.version.to_s }
  #s.source           = { :git => 'file:///Users/dimi/Projects/Xcode/Rigi/Rigi-Source' } # for local compiling

  #s.platform          = :ios, '10.0'
  s.swift_version     = '5.0'
  s.ios.deployment_target = '10.0'
  s.frameworks        = 'UIKit'

  s.source_files      = 'Rigi/Classes/*'
  s.resources         = 'Rigi/Assets/*', 'Rigi/Bin/*', 'Rigi/Docs/*'
  s.preserve_paths    = ['Bin/*', , 'Docs/*']
end
