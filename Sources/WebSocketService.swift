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

import Network
import Foundation

/// Frames
public enum WebSocketFrame {
	case data(Data)
	case string(String)
	case ping
	case unknown

}

/// WebSocket events
public enum WebSocketEvents {
	case connected
	case disconnected(Int, Data?)
	case frame(WebSocketFrame)
	case error(Error?)

}

/// WebSocket error
enum WebSocketError: Error, CustomStringConvertible {
	case taskNotCreated

	var description: String {
		switch self {
		case .taskNotCreated:
			"WebSocket task not created"
		}
	}

}

/// WebSocket events handler
public protocol WebSocketEventsDelegate: AnyObject {
	func handle(event: WebSocketEvents)

}

/// WebSocket service
public protocol WebSocketService {
	var webSocketEventsDelegate: WebSocketEventsDelegate? { get set }
	init(delegateQueue: OperationQueue, request: URLRequest)
	func create()
	func reconnect(nanoseconds: UInt64) async throws
	func send(frame: WebSocketFrame) async throws
	func connect() async throws
	func disconnect(code: Int, reason: Data?)
	func receive() async throws

}

/// WebSocket Manager
public class WebSocketManager: NSObject, WebSocketService {
	public weak var webSocketEventsDelegate: WebSocketEventsDelegate?
	public private(set) var isConnected = false
	private let delegateQueue: OperationQueue
	private let request: URLRequest
	private var sessionWebSocketTask: URLSessionWebSocketTask?

	///WebSocket
	/// - Parameters:
	///     - delegateQueue: for URLSession
	///     - request: must contain ws:// or wss://
	public required init(
		delegateQueue: OperationQueue = OperationQueue(),
		request: URLRequest
	) {
		self.delegateQueue = delegateQueue
		self.request = request
		super.init()
		create()
	}

	///Create new webSocketTask
	public func create() {
		let urlSession = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: delegateQueue)
		sessionWebSocketTask = urlSession.webSocketTask(with: request)
	}

	/// Resume WebSocket task, start listening for a response
	public func connect() async throws {
		sessionWebSocketTask?.resume()
		try await receive()
	}

	///reconnectWebSocket
	/// - Parameters:
	///     - nanoseconds: delay to reconnect
	public func reconnect(
		nanoseconds: UInt64
	) async throws {
		disconnect(code: 1000, reason: nil)
		create()
		try await Task.sleep(nanoseconds: nanoseconds)
		try await connect()
	}

	///webSocketSend
	/// - Parameters:
	///     - frame: send `WebSocketFrame` with options: data, string, ping, unknown
	public func send(
		frame: WebSocketFrame
	) async throws {
		switch frame {
		case .data(let data):
			try? await sessionWebSocketTask?.send(.data(data))
		case .string(let string):
			try? await sessionWebSocketTask?.send(.string(string))
		case .ping:
			try? await withCheckedThrowingContinuation { [weak sessionWebSocketTask] (continuation: CheckedContinuation<Void, Error>) in
				sessionWebSocketTask?.sendPing { error in
					guard let error = error else {
						continuation.resume(returning: ())
						return
					}
					continuation.resume(throwing: error)
				}
			}
		case .unknown:
			break
		}
	}

	///disconnect
	/// - Parameters:
	///     - code: Int
	///     - reason: Data
	public func disconnect(
		code: Int,
		reason: Data?
	) {
		sessionWebSocketTask?.cancel(with: URLSessionWebSocketTask.CloseCode(rawValue: code) ?? .normalClosure, reason: reason)
	}

	///Listening webSocket response
	public func receive() async throws {
		guard let message = try await sessionWebSocketTask?.receive() else {
			throw WebSocketError.taskNotCreated
		}
		switch message {
		case .data(let data):
			webSocketEventsDelegate?.handle(event: .frame(.data(data)))
		case .string(let string):
			webSocketEventsDelegate?.handle(event: .frame(.string(string)))
		@unknown default:
			webSocketEventsDelegate?.handle(event: .frame(.unknown))
		}
		try await receive()
	}

}

//Check status of webSocket connection
extension WebSocketManager: URLSessionWebSocketDelegate {
	public func urlSession(
		_ session: URLSession,
		webSocketTask: URLSessionWebSocketTask,
		didOpenWithProtocol protocol: String?
	) {
		isConnected = true
		webSocketEventsDelegate?.handle(event: .connected)
	}

	public func urlSession(
		_ session: URLSession,
		webSocketTask: URLSessionWebSocketTask,
		didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
		reason: Data?
	) {
		isConnected = false
		webSocketEventsDelegate?.handle(event: .disconnected(closeCode.rawValue, reason))
	}

	public func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		didCompleteWithError error: Error?
	) {
		webSocketEventsDelegate?.handle(event: .error(error))
	}

}
