public struct SendStompFrame: StompFrameProtocol {
    public var command: String {
        return BasicCommands.send
    }
    public var headers: [String : String]
    public var body: String?
    
    ///STOMP frame SEND with
    /// - Parameters:
    ///     - body: string body
    ///     - destination: destination
    ///     - headers: optional headers
    ///     - transaction: transaction
    public init(body: String, destination: String, headers: [String : String]?, transaction: String?) {
        var sendHeaders = [String : String]()

        if let additionalHeaders = headers {
            sendHeaders = additionalHeaders
        }

        if let transaction = transaction {
            sendHeaders[HeaderCommands.transaction] = transaction
        }

        if !sendHeaders.contains(where: { $0.key == HeaderCommands.contentType }) {
            sendHeaders[HeaderCommands.contentType] = "text/plain"
        }

        sendHeaders[HeaderCommands.destination] = destination
        sendHeaders[HeaderCommands.contentLength] = "\(body.utf8.count)"

        self.headers = sendHeaders
        self.body = body
    }
}
