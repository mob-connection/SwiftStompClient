public struct CommitStompFrame: StompFrameProtocol {
	public var command: String {
		BasicCommands.commit
	}
	public var headers: [String : String]
	public var body: String?

	///STOMP frame COMMIT with
	/// - Parameters:
	///     - transactionId: transaction Id
	public init(
		transactionId: String
	) {
		let commitHeaders = [HeaderCommands.transaction : transactionId]
		headers = commitHeaders
	}

}
