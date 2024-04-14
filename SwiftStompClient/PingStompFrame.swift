public struct PingStompFrame: StompFrameProtocol {
	///STOMP frame PING with empty headers
	public var command: String {
		BasicCommands.ping
	}
	public var headers: [String : String] = [String : String]()
	public var body: String?

}
