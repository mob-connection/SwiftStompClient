import Foundation

public struct DisconnectStompFrame: StompFrameProtocol {
	public var command: String {
		BasicCommands.disconnect
	}
	public var headers: [String : String]
	public var body: String?

	///STOMP frame DISCONNECT with  disconnected time in
	public init() {
		let disconnectHeaders = [HeaderCommands.disconnected : "\(Int(Date().timeIntervalSince1970))"]
		headers = disconnectHeaders
	}

}
