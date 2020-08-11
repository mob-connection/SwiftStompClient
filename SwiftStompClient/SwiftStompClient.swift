import Foundation

///STOMP protocol handle webSocket open/close state for sending CONNECT STOMP frame
public protocol StompProtocol: class {
    func clientSendFrame(result: Result<Void, Error>)
    func clientReciveFrame(stomp: SwiftStompClient, frameType: SwiftStompClient.FrameResponseKeys, headers: [String: String], body: String?)
    func handleWebSocketResponse(result: Result<URLSessionWebSocketTask.Message, Error>)
    func handleWebSocketConnect(session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol: String?)
    func handleWebSocketDisconnect(session: URLSession, webSocketTask: URLSessionWebSocketTask, closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}

public class SwiftStompClient {
    
    ///Basic server frames
    public enum FrameResponseKeys: String {
        case connected = "CONNECTED"
        case message = "MESSAGE"
        case receipt = "RECEIPT"
        case error = "ERROR"
        case ping = "\n"
    }

    public let webSocket: WebSocket
    public let heartBeat: HeartBeat?
    
    public weak var stompDelegate: StompProtocol?
    
    ///Init with webSocket
    /// - Parameters:
    ///     - webSocket: WebSocket
    ///     - heartBeat: HeartBeat
    public init(webSocket: WebSocket, heartBeat: HeartBeat? = nil) {
        self.webSocket = webSocket
        self.heartBeat = heartBeat
        self.webSocket.webSocketDelegate = self
        //
        sendPingFrame()
        sendDisconnectFrame()
    }
    
    private func sendPingFrame() {
        heartBeat?.pingAction = { [weak self] in
            let pingFrame = PingStompFrame()
            self?.sendFrame(frame: pingFrame)
        }
    }
    
    private func sendDisconnectFrame() {
        heartBeat?.pongAction = { [weak self] in
            let disconnectFrame = DisconnectStompFrame()
            self?.sendFrame(frame: disconnectFrame)
        }
    }
    
    ///Open webSocket connection
    public func openWebSocketConnection() {
        webSocket.connect()
    }
    
    ///Close webSocket connection
    public func closeWebSocketConnection() {
        webSocket.disconnect(code: .normalClosure, reason: nil)
    }

    ///Send frames via webSocket with
    /// - Parameters:
    ///     - command: basic server commands
    ///     - headers: additionaly headers for making correct frame
    ///     - body: body for frame if needed
    public func sendFrame(frame: StompFrameProtocol) {
        var stompFrame = String()
        
        //add command
        stompFrame.append(frame.command + "\n")
        
        //add headers
        frame.headers.forEach({
            stompFrame.append($0.key + ":" + $0.value + "\n")
        })
        
        stompFrame.append("\n")
        
        //add body if exist
        if let body = frame.body {
            stompFrame.append("\n" + body)
        }
        
        //add control char
        stompFrame.append(BasicCommands.controlChar)
        
        webSocket.webSocketSend(message: .string(stompFrame), onResult: { [weak stompDelegate] in
            stompDelegate?.clientSendFrame(result: $0)
        })
    }
    
    ///Handle server frames with heart-beat implementation
    private func receiveFrame(commands: String, headers: [String : String], body: String? = nil) {
        guard let command = FrameResponseKeys(rawValue: commands) else {
            print("ERROR FRAME HANDLING COMMAND: \(commands), HEADERS: \(headers), BODY: \(body?.description ?? "empty body")")
            return
        }
        stompDelegate?.clientReciveFrame(stomp: self, frameType: command, headers: headers, body: body)
        heartBeat?.handleFrames(headers: headers, frame: command)
    }
    
    ///Decode string on fragments command, headers, body
    private func decodeString(webSocketString: String) {
        var headers = [String: String]()
        var body = String()
        
        //handling ping frame
        guard webSocketString == "\n" else {
            var hasHeaders = true
            var contents = webSocketString.components(separatedBy: "\n")
            
            if contents.first == "" {
                contents.removeFirst()
            }

            guard let command = contents.first else {
                print("current decoded string doesn't containe any command")
                return
            }
            
            //remove command after reading
            contents.removeFirst()
                
            contents.forEach({
                if hasHeaders && !$0.isEmpty {
                    let headersComponents = $0.components(separatedBy: ":")
                    if let key = headersComponents.first {
                        headers[key] = headersComponents.dropFirst().joined(separator: ":")
                    }
                } else {
                    hasHeaders = false
                    body.append($0)
                }
            })
            receiveFrame(commands: command, headers: headers, body: body)
            return
        }
        receiveFrame(commands: "\n", headers: headers, body: body)
    }
    
    ///Handle webSocket responce
    /// - Parameters:
    ///     - responce: data, string or error
    private func handleWebSocketResult(responce: Result<URLSessionWebSocketTask.Message, Error>) {
        do {
            let responce = try responce.get()
            switch responce {
            case .data(let dataFrame):
                guard let decodedFrame = String(data: dataFrame, encoding: .utf8) else {
                    print("can't convert data to string in function \(#function)")
                    return
                }
                decodeString(webSocketString: decodedFrame)
            case .string(let frame):
                decodeString(webSocketString: frame)
            @unknown default:
                print("unknown default webSocket responce")
            }
        } catch let error {
            print("webSocket handle error: \(error.localizedDescription)")
        }
    }
}

extension SwiftStompClient: WebSocketProtocol {
    public func handleConnect(session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol: String?) {
        stompDelegate?.handleWebSocketConnect(session: session, webSocketTask: webSocketTask, didOpenWithProtocol: didOpenWithProtocol)
    }
    
    public func handleDisconnect(session: URLSession, webSocketTask: URLSessionWebSocketTask, closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        stompDelegate?.handleWebSocketDisconnect(session: session, webSocketTask: webSocketTask, closeCode: closeCode, reason: reason)
    }
    
    public func handleResponse(result: Result<URLSessionWebSocketTask.Message, Error>) {
        handleWebSocketResult(responce: result)
        stompDelegate?.handleWebSocketResponse(result: result)
    }
}
