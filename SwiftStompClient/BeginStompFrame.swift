public struct BeginStompFrame: StompFrameProtocol {
    public var command: String {
        return BasicCommands.begin
    }
    public var headers: [String : String]
    public var body: String?
    
    ///STOMP frame BEGIN with
    /// - Parameters:
    ///     - transactionId: transaction Id
    public init(transactionId: String) {
        let beginHeaders = [HeaderCommands.transaction : transactionId]
        self.headers = beginHeaders
    }
}
