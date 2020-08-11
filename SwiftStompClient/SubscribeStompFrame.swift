public struct SubscribeStompFrame: StompFrameProtocol {
    public var command: String {
        return BasicCommands.subscribe
    }
    public var headers: [String : String]
    public var body: String?
    
    ///STOMP frame SUBSCRIBE with
    /// - Parameters:
    ///     - destination: destination
    ///     - destinationId: destinationId
    ///     - ackMode: ack mode by default is auto
    public init(destination: String, destinationId: String, ackMode: AckMode = .auto) {
        let subscribeHeaders = [HeaderCommands.destination : destination,
                                HeaderCommands.destinationId : destinationId,
                                HeaderCommands.ack : ackMode.rawValue]
        self.headers = subscribeHeaders
    }

    ///STOMP frame SUBSCRIBE with headers
    /// - Parameters:
    ///     - destination: destination
    ///     - headers: headers
    public init(destination: String, headers: [String : String]) {
        var subscribeHeaders = headers
        subscribeHeaders[HeaderCommands.destination] = destination
        self.headers = subscribeHeaders
    }
}
