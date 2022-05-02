
Pod::Spec.new do |s|
  s.name              = 'Rigi'
  s.version           = '1.0.1'
  s.summary           = 'Makes Rigi previews for your iOS project.'
  s.homepage          = 'https://rigi.io'
  s.author            = { 'Name' => 'dimitri@rigi.io' }
  s.license           = { :type => 'Copyright', :text => 'Copyright 2022 Rigi.io'}

  s.source            = { :git => 'https://github.com/Dimi70/rigi-ios-sdk.git', :tag => s.version.to_s }
  #s.source           = { :git => 'file:///Users/dimi/Projects/Xcode/Rigi/Rigi-Source' } # for local compiling
  #s.source            = { :git => 'https://github.com/Dimi70/rigi-ios-sdk/1.0.0.zip', :tag => s.version.to_s } # for compiled framework

  s.swift_versions    = '5.0'
  s.platform          = :ios, '10.0'
  s.frameworks        = 'UIKit'

 s.subspec 'bin' do |bin|
   bin.source_files = 'bin/**'
 end

 s.subspec 'docs' do |docs|
   docs.source_files = 'docs/**'
 end

  # Group swift files in Pod source
  s.subspec 'Classes' do |classes|
    classes.source_files = 'Rigi/Classes/**'
  end

  # Add assets to Pod source
  s.resources         = 'Rigi/Assets/**'

  # Preserve these files in the Pods folder
  s.preserve_paths    = ['Rigi/**', 'bin/**', 'docs/**']
end
