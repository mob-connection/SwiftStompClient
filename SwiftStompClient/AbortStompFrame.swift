public struct AbortStompFrame: StompFrameProtocol {
	public var command: String {
		BasicCommands.abort
	}
	public var headers: [String : String]
	public var body: String?

	///STOMP frame ABORT with
	/// - Parameters:
	///     - transactionId: transaction Id
	public init(
		transactionId: String
	) {
		let abortHeaders = [HeaderCommands.transaction : transactionId]
		headers = abortHeaders
	}

}
