Pod::Spec.new do |spec|

  spec.name         = "SwiftStompClient"
  spec.version      = "0.0.1"
  spec.summary      = "STOMP implementation on native WebSocket implementation with optional heart-beating iOS 13.0+ macOS 10.15+ Mac Catalyst 13.0+ tvOS 13.0+ watchOS 6.0+"

  spec.homepage     = "https://github.com/mob-connection/SwiftStompClient"

  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "mob-connection" => "ozhurbaiosdevelop@gmail.com" }

  spec.ios.deployment_target = "13.0"

  spec.source        = { :git => "https://github.com/mob-connection/SwiftStompClient.git", :tag => "#{spec.version}" }
  spec.source_files  = "SwiftStompClient/**/*.{h,m,swift}"

end
