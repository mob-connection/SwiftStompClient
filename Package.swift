// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
let package = Package(
	name: "SwiftStompClient",
	platforms: [
		.macOS(.v12),
			.iOS(.v15),
			.tvOS(.v15),
			.watchOS(.v8)
	],
	products: [
		.library(
			name: "SwiftStompClient",
			targets: ["SwiftStompClient"]
		),
		.library(
			name: "SwiftStompClientDynamic",
			type: .dynamic,
			targets: ["SwiftStompClient"]
			)
	],
	targets: [
		.target(
			name: "SwiftStompClient",
			path: "Sources",
			exclude: ["Info.plist"],
			resources: [
				.process("PrivacyInfo.xcprivacy")
			]
		)
	],
	swiftLanguageVersions: [.v5]
)

