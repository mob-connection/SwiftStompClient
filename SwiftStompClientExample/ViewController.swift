//  MIT License
//
//  Copyright (c) 2020-2024 mob-connection (Oleksandr Zhurba)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

class ViewController: UIViewController {
	enum NetworkConstants {
		static let baseSTOMP = URL(string: "ws://192.168.0.219:8080/ws")!
		static let baseWebSocket = URL(string: "wss://echo.websocket.org")!
	}

	private let webSocket: WebSocketService = {
		var urlRequest = URLRequest(url: NetworkConstants.baseSTOMP)
		urlRequest.timeoutInterval = 2
		let webSocket = WebSocketManager(request: urlRequest)
		return webSocket
	}()

	private let heartBeat: HeartBeatService = HeartBeatManager(clientHeartBeating: "2000,5000", clientSendingLeeway: 0.0)
	lazy var stompClient: SwiftStompClient = .init(webSocket: webSocket, heartBeat: heartBeat)

	override func viewDidLoad() {
		super.viewDidLoad()

		stompClient.stompDelegate = self

		Task { [weak self] in
			guard let self = self else { return }
			try await self.stompClient.openWebSocketConnection()
		}

		NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(appMovedFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	@objc func appMovedToBackground() {
		Task { [weak stompClient] in
			let disconnectStompFrame = DisconnectStompFrame()
			try await stompClient?.sendFrame(frame: disconnectStompFrame)
			stompClient?.disconnectWebSocket(code: 100, reason: nil)
		}
	}

	@objc func appMovedFromBackground() {
		Task { [weak stompClient] in
			try await stompClient?.reconnectWebSocket(nanoseconds: 0)
			let connectFrame = ConnectStompFrame(acceptVersion: "1.1,1.2", heartBeat: "2000,5000")
			try await stompClient?.sendFrame(frame: connectFrame)
		}
	}

	private func send(frame: StompFrameProtocol) {
		Task { [weak stompClient] in
			try await stompClient?.sendFrame(frame: frame)
		}
	}

	//MARK: Actions
	@IBAction func ask(_ sender: UIButton) {
		let ack = AckStompFrame(messageId: "1", subscription: "1")
		send(frame: ack)
	}

	@IBAction func abort(_ sender: UIButton) {
		let abort = AbortStompFrame(transactionId: "1")
		send(frame: abort)
	}

	@IBAction func begin(_ sender: UIButton) {
		let begin = BeginStompFrame(transactionId: "1")
		send(frame: begin)
	}

	@IBAction func commit(_ sender: UIButton) {
		let commit = CommitStompFrame(transactionId: "1")
		send(frame: commit)
	}

	@IBAction func connect(_ sender: UIButton) {
		Task { [weak stompClient] in
			try await stompClient?.reconnectWebSocket(nanoseconds: 0)
			let connect = ConnectStompFrame(acceptVersion: "1.1,1.2", heartBeat: "2000,5000")
			send(frame: connect)
		}
	}

	@IBAction func disconnect(_ sender: UIButton) {
		let disconnect = DisconnectStompFrame()
		send(frame: disconnect)
	}

	@IBAction func ping(_ sender: UIButton) {
		let ping = PingStompFrame(headers: ["top" : "bottom"], body: "PingStompFrame")
		send(frame: ping)
	}

	@IBAction func send(_ sender: UIButton) {
		let sendFrame = SendStompFrame(body: "Body", destination: "/user", headers: nil, transaction: nil)
		send(frame: sendFrame)
	}

	@IBAction func subscribe(_ sender: UIButton) {
		let subscribe = SubscribeStompFrame(destination: "\0", destinationId: "1", ackMode: .client)
		send(frame: subscribe)
	}

	@IBAction func unsubscribe(_ sender: UIButton) {
		let unsubs = UnsubscribeStompFrame(destination: "\0")
		send(frame: unsubs)
	}

}

extension ViewController: StompClientDelegate {
	func receiveStomp(
		frame: SwiftStompClient,
		type: FrameResponseKeys,
		headers: [String : String],
		body: String?
	) {
		print("receiveFrame: \(frame), frameType: \(type), headers: \(headers), body: \(body))")
	}

	func webSocketConnected() {
		Task { [weak self] in
			let connectFrame = ConnectStompFrame(acceptVersion: "1.1,1.2", heartBeat: "2000,5000")
			try await self?.stompClient.sendFrame(frame: connectFrame)
		}
	}

	func webSocketDisconnected(
		closeCode: Int,
		reason: Data?
	) {
		print("webSocketDisconnected closeCode: \(closeCode), reason: \(reason))")
	}

	func handle(
		error: SwiftStompError
	) {
		//reconnect webSocket after server dropping
		if case .webSocket(let err) = error, let err {
			Task { [weak stompClient] in
				try await stompClient?.reconnectWebSocket(nanoseconds: 1_000_000_000)
			}
		}
	}

}
