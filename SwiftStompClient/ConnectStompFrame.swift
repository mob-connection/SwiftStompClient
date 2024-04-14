public struct ConnectStompFrame: StompFrameProtocol {
	public var command: String {
		BasicCommands.connect
	}
	public var headers: [String : String]
	public var body: String?
	public var clientHeartBeat: String?

	///STOMP frame CONNECT with
	/// - Parameters:
	///     - acceptVersion: STOMP version
	///     - login: login
	///     - passcode: passcode
	///     - host: host
	///     - heartBeat: optional value heart-beat
	public init(
		acceptVersion: String,
		login: String,
		passcode: String,
		host: String,
		heartBeat client: String? = nil
	) {
		var connectionHeaders = [HeaderCommands.acceptVersion : acceptVersion,
								 HeaderCommands.login : login,
								 HeaderCommands.passcode : passcode,
								 HeaderCommands.host : host]
		if let clientHeartBeat = client {
			self.clientHeartBeat = clientHeartBeat
			connectionHeaders[HeaderCommands.heartBeat] = clientHeartBeat
		}
		headers = connectionHeaders
	}

	///STOMP frame CONNECT with
	/// - Parameters:
	///     - acceptVersion: accept STOMP version
	///     - heartBeat: optional value heart-beat
	public init(
		acceptVersion: String,
		heartBeat client: String? = nil
	) {
		var connectionHeaders = [HeaderCommands.acceptVersion : acceptVersion]

		if let clientHeartBeat = client {
			self.clientHeartBeat = clientHeartBeat
			connectionHeaders[HeaderCommands.heartBeat] = clientHeartBeat
		}
		headers = connectionHeaders
	}

}
