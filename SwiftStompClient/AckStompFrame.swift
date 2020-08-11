public struct AckStompFrame: StompFrameProtocol {
    public var command: String {
        return BasicCommands.ack
    }
    public var headers: [String : String]
    public var body: String?
    
    ///STOMP frame ACK with
    /// - Parameters:
    ///     - messageId: message Id
    ///     - subscription: optional value subscription
    public init(messageId: String, subscription: String?) {
        var ackHeaders = [HeaderCommands.headerMessageId : messageId]
        if let subscription = subscription {
            ackHeaders[HeaderCommands.subscription] = subscription
        }
        self.headers = ackHeaders
    }
}
