Pod::Spec.new do |spec|
  spec.name         = "DRRoutes"
  spec.version      = "0.0.1"
  spec.summary      = "Swift router manager."
  spec.description  = <<-DESC
                    这是一个采用swift实现的路由管理工具
                   DESC

  spec.homepage     = "https://github.com/githubzb/DRRoutes"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "drbox" => "1126976340@qq.com" }
  spec.platform     = :ios, "10.0"
  spec.swift_version = "5.0"
#  spec.source       = { :git => "https://github.com/githubzb/DRRoutes.git", :tag => "#{spec.version}" }
  spec.source       = { :git => "https://github.com/githubzb/DRRoutes.git", :commit => "#{spec.version}" }

  spec.source_files  = "DRRoutes/class/**/*.{swift}"
#  spec.exclude_files = "Classes/Exclude"
  spec.public_header_files = "DRRoutes/DRRoutes.h"
  spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
