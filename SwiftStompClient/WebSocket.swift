import Network
import Foundation

public protocol WebSocketProtocol: class {
    func handleConnect(session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol: String?)
    func handleDisconnect(session: URLSession, webSocketTask: URLSessionWebSocketTask, closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    func handleResponse(result: Result<URLSessionWebSocketTask.Message, Error>)
}

public class WebSocket: NSObject {
    ///URLSession with configuration
    private lazy var urlSession: URLSession = { [weak self, unowned delegateQueue] in
        return URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
    }()
    
    ///Operation queue by default set maximum concurrent operation count
    public var delegateQueue = OperationQueue()
    
    ///WebSocket task
    public var sessionWebSocketTask: URLSessionWebSocketTask!
    
    ///WebSocket delegate
    public weak var webSocketDelegate: WebSocketProtocol?
    
    public private(set) var isConnected = false

    ///Init with request
    /// - Parameters:
    ///     - request: must contain ws:// or wss://
    public init(request: URLRequest) {
        super.init()
        self.sessionWebSocketTask = urlSession.webSocketTask(with: request)
    }
    
    ///Send ping with completions
    /// - Parameters:
    ///     - onSuccess: success send ping frame
    ///     - onError: error with Error
    public func webSocketSendPing(onSuccess: @escaping ((Result<Void, Error>) -> Void)) {
        sessionWebSocketTask.sendPing(pongReceiveHandler: {
            $0 == nil ? onSuccess(.success(())) : onSuccess(.failure($0!))
        })
    }
    
    ///Send webSocket message  with completions
    /// - Parameters:
    ///     - message: URLSessionWebSocketTask.Message
    ///     - onSuccess: successed send webSocket message
    ///     - onError: error with Error
    public func webSocketSend(message: URLSessionWebSocketTask.Message, onResult: @escaping ((Result<Void, Error>) -> Void)) {
        sessionWebSocketTask.send(message, completionHandler: {
            $0 == nil ? onResult(.success(())) : onResult(.failure($0!))
        })
    }
    
    ///Connect webSocket connection
    public func connect() {
        webSocketReceive()
        sessionWebSocketTask.resume()
    }
    
    ///Disconnect webSocket connection
    public func disconnect(code: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        sessionWebSocketTask.cancel(with: code, reason: reason)
    }
    
    ///Handle webSocket responce
    private func webSocketReceive() {
        sessionWebSocketTask.receive(completionHandler: { [weak webSocketDelegate] in
            webSocketDelegate?.handleResponse(result: $0)
            if let _ = try? $0.get() {
                self.webSocketReceive()
            }
        })
    }
}

///Handle webSocket open/close actions
extension WebSocket: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        webSocketDelegate?.handleConnect(session: session, webSocketTask: webSocketTask, didOpenWithProtocol: `protocol`)
        isConnected = true
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        webSocketDelegate?.handleDisconnect(session: session, webSocketTask: webSocketTask, closeCode: closeCode, reason: reason)
        isConnected = false
    }
}
