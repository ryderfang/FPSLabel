Pod::Spec.new do |s|
  s.name         = "FPSLabel"
  s.version      = "1.0.2"
  s.summary      = "A draggble label that display FPS."                 
  s.homepage     = "https://github.com/qkzhu/FPSLabel"
  s.license      = { :type => 'MIT' }
  s.author       = { "qiankun" => "zqkun.public@gmail.com" }

  s.platform     = :ios
  s.ios.deployment_target = "12.0"
  s.swift_version = '5.0'
  s.source       = { :git => "https://github.com/ryderfang/FPSLabel.git", :tag => s.version }
  s.source_files = "FPSLabel/*.swift"
  s.requires_arc = true
end
