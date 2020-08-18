

Pod::Spec.new do |s|
  s.name             = 'KojiPlayerHelper'
  s.version          = '0.0.1'
  s.summary          = 'UIView for rendering Kojis'
  s.swift_version    = '4.2'
  s.description      = <<-DESC
A helper library for rendering [Kojis](https://withkoji.com) in iOS applications
                       DESC
  s.homepage         = 'https://github.com/madewithkoji/koji-sdk'
  s.author           = { 'Sean Thielen' => 'sean@gometa.io' }
  
  s.source           = { :git => 'https://github.com/madewithkoji/koji-ios-player-helper.git' }
  s.ios.deployment_target = '8.0'
  s.source_files = 'KojiPlayerHelper/Classes/**/*'
  s.resource_bundles = {
     'KojiPlayerHelper' => ['KojiPlayerHelper/Assets/*']
  }
end
