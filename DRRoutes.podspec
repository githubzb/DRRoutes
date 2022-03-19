Pod::Spec.new do |spec|
  spec.name         = "DRRoutes"
  spec.version      = "0.0.1"
  spec.summary      = "Swift router manager."
  spec.description  = <<-DESC
                    这是一个采用swift实现的路由管理工具，支持全局与部分路由注册，路由未匹配的处理等。
                    同时增加了Navigator，主要用于实现模块内部页面导航。
                   DESC

  spec.homepage     = "https://github.com/githubzb/DRRoutes"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "drbox" => "1126976340@qq.com" }
  spec.platform     = :ios, "10.0"
  spec.swift_version = "5.0"
#  spec.source       = { :git => "https://github.com/githubzb/DRRoutes.git", :tag => "#{spec.version}" }
  spec.source       = { :git => "https://github.com/githubzb/DRRoutes.git", :commit => "67f2d0d" }

  spec.source_files  = "DRRoutes/class/**/*.{swift}"
#  spec.exclude_files = "Classes/Exclude"
  spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
