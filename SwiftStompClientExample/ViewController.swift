//
//  ViewController.swift
//  SwiftStompClientExample
//
//  Created by Oleksandr Zhurba on 11.08.2020.
//  Copyright © 2020 Oleksandr Zhurba. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    struct NetworkConstants {
        static let baseSTOMP = URL(string: "ws://127.0.0.1:8080/ws")!
        static let baseWebSocket = URL(string: "wss://echo.websocket.org")!
    }

    let webSocket = WebSocket(request: URLRequest(url: NetworkConstants.baseSTOMP))
    
    let heartBeat = HeartBeat(clientHeartBeating: "2000,5000")
    
    lazy var stompClient = SwiftStompClient(webSocket: webSocket, heartBeat: heartBeat)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stompClient.stompDelegate = self
        stompClient.openWebSocketConnection()
    }
}

extension ViewController: StompProtocol {
    func clientSendFrame(result: Result<Void, Error>) {
        print("client did send frame \(result)")
    }
    
    func clientReciveFrame(stomp: SwiftStompClient, frameType: SwiftStompClient.FrameResponseKeys, headers: [String : String], body: String?) {
        print("server did recive frame")
        print(frameType)
        print(stomp)
        print(headers)
        print(body ?? "empty body")
    }
    
    func handleWebSocketResponse(result: Result<URLSessionWebSocketTask.Message, Error>) {
        print("handle WebSocketResponse \(result)")
    }
    
    func handleWebSocketConnect(session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol: String?) {
        print("handle opening webSocket connection")
        let connectFrame = ConnectStompFrame(acceptVersion: "1.1,1.2", heartBeat: "2000,5000")
        stompClient.sendFrame(frame: connectFrame)
    }
    
    func handleWebSocketDisconnect(session: URLSession, webSocketTask: URLSessionWebSocketTask, closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("webSocket is disconnected")
    }
}
