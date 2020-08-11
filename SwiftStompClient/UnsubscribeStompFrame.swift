public struct UnsubscribeStompFrame: StompFrameProtocol {
    public var command: String {
        return BasicCommands.unsubscribe
    }
    public var headers: [String : String]
    public var body: String?
    
    ///STOMP frame UNSUBSCRIBE with
    /// - Parameters:
    ///     - destination: destination
    public init(destination: String) {
        let unsubscribeHeaders = [HeaderCommands.destination : destination]
        self.headers = unsubscribeHeaders
    }
}
