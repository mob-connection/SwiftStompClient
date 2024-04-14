Pod::Spec.new do |spec|

  spec.name         = "SwiftStompClient"
  spec.version      = "0.0.8"
  spec.summary      = "STOMP implementation on native WebSocket in Swift"
  spec.description  = <<-DESC
Swift [STOMP](https://stomp.github.io) client for swift via [WebSocketTask](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask) with [Heart-beating](https://stomp.github.io/stomp-specification-1.2.html#Heart-beating) iOS 15.0+ macOS 12.0+ tvOS 15.0+ watchOS 8.0+
DESC
  spec.homepage     = "https://github.com/mob-connection/SwiftStompClient"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "mob-connection" => "ozhurbaiosdevelop@gmail.com" }

  spec.ios.deployment_target = "15.0"
  spec.osx.deployment_target = '12.0'
  spec.tvos.deployment_target = '15.0'
  spec.watchos.deployment_target = '8.0'

  spec.swift_version = "5.5"
  spec.source = { :git => "https://github.com/mob-connection/SwiftStompClient.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/**/*.swift"
  spec.resource_bundles = {'Sources' => ['Sources/PrivacyInfo.xcprivacy']}

end
