import Foundation

/// STOMP Errors
public enum SwiftStompError: Error, CustomStringConvertible {
	case dataString
	case noCommand
	case undefinedFrame(commands: String, headers: [String : String], body: String?)
	case ping(error: Error)
	case pong(error: Error)
	case webSocket(error: Error?)
	case heartBeat(error: Error)

	public var description: String {
		switch self {
		case .dataString:
			"Can not convert data to string"
		case .noCommand:
			"Current frame doesn't containe any command"
		case .undefinedFrame(let commands, let headers, let body):
			"Can not parse commands: \(commands), headers: \(headers), body: \(body))"
		case .webSocket(let error):
			"WebSocket error: \(error))"
		case .ping(let error):
			"Heart beat ping error: \(error)"
		case .pong(let error):
			"Heart beat pong error: \(error)"
		case .heartBeat(let error):
			"Heart beat error: \(error)"
		}
	}

}

///STOMP protocol handle webSocket open/close state
public protocol StompClientDelegate: AnyObject {
	func receiveStomp(frame: SwiftStompClient, type: FrameResponseKeys, headers: [String: String], body: String?)
	func webSocketConnected()
	func webSocketDisconnected(closeCode: Int, reason: Data?)
	func handle(error: SwiftStompError)

}

public class SwiftStompClient {
	private var webSocket: WebSocketService
	private var heartBeat: HeartBeatService?
	public weak var stompDelegate: StompClientDelegate?

	///Init with webSocket
	/// - Parameters:
	///     - webSocket: WebSocket
	///     - heartBeat: HeartBeat
	public init(
		webSocket: WebSocketService,
		heartBeat: HeartBeatService? = nil
	) {
		self.webSocket = webSocket
		self.heartBeat = heartBeat
		self.webSocket.webSocketEventsDelegate = self
		recallHeartBeat()
	}

	private func recallHeartBeat() {
		sendPing()
		sendDisconnect()
		heartBeatErrorHandle()
	}

	private func sendPing() {
		heartBeat?.pingAction = { [weak self] in
			let pingFrame = PingStompFrame()
			Task { [weak self] in
				do {
					try await self?.sendFrame(frame: pingFrame)
				} catch {
					self?.stompDelegate?.handle(error: .ping(error: error))
				}
			}
		}
	}

	private func sendDisconnect() {
		heartBeat?.pongAction = { [weak self] in
			let disconnectFrame = DisconnectStompFrame()
			Task { [weak self] in
				do {
					try await self?.sendFrame(frame: disconnectFrame)
					self?.recallHeartBeat()
				} catch {
					self?.stompDelegate?.handle(error: .pong(error: error))
				}
			}
		}
	}

	private func heartBeatErrorHandle() {
		heartBeat?.errorAction = { [weak self] error in
			self?.stompDelegate?.handle(error: .heartBeat(error: error))
		}
	}

	public func reconnectWebSocket(
		nanoseconds: UInt64
	) async throws {
		try await webSocket.reconnect(nanoseconds: nanoseconds)
	}

	public func disconnectWebSocket(
		code: Int,
		reason: Data?
	) {
		webSocket.disconnect(code: code, reason: reason)
	}

	///Open webSocket connection
	public func openWebSocketConnection() async throws {
		try await webSocket.connect()
	}

	///Close webSocket connection
	public func disconnectWebSocket(
		code: Int,
		data: Data? = nil
	) {
		webSocket.disconnect(code: (URLSessionWebSocketTask.CloseCode(rawValue: code) ?? .normalClosure).rawValue, reason: data)
	}

	///Send frames via webSocket with
	/// - Parameters:
	///     - command: basic server commands
	///     - headers: additionaly headers for making correct frame
	///     - body: body for frame if needed
	public func sendFrame(
		frame: StompFrameProtocol
	) async throws {
		var stompFrame = String()

		//add command
		stompFrame.append(frame.command + "\n")

		//add headers
		frame.headers.forEach {
			stompFrame.append($0.key + ":" + $0.value + "\n")
		}

		stompFrame.append("\n")

		//add if body exist
		if let body = frame.body {
			stompFrame.append("\n" + body)
		}

		//add control char
		stompFrame.append(BasicCommands.controlChar)

		try await webSocket.send(frame: .string(stompFrame))
	}

	///Receive server frame with heart beat implementation
	private func receiveFrame(
		commands: String,
		headers: [String : String],
		body: String? = nil
	) {
		guard let command = FrameResponseKeys(rawValue: commands) else {
			stompDelegate?.handle(error: .undefinedFrame(commands: commands, headers: headers, body: body))
			return
		}
		stompDelegate?.receiveStomp(frame: self, type: command, headers: headers, body: body)
		heartBeat?.handler(headers: headers, frame: command)
	}

	///Decode string on fragments command, headers, body
	private func decode(
		string: String
	) {
		var headers = [String: String]()
		var body = String()

		//handling ping frame
		guard string == FrameResponseKeys.ping.rawValue else {
			var hasHeaders = true
			var contents = string.components(separatedBy: "\n")

			if contents.first == "" {
				contents.removeFirst()
			}

			guard let command = contents.first else {
				stompDelegate?.handle(error: .noCommand)
				return
			}

			//remove command after reading
			contents.removeFirst()

			contents.forEach {
				if hasHeaders && !$0.isEmpty {
					let headersComponents = $0.components(separatedBy: ":")
					if let key = headersComponents.first {
						headers[key] = headersComponents.dropFirst().joined(separator: ":")
					}
				} else {
					hasHeaders = false
					body.append($0)
				}
			}
			receiveFrame(commands: command, headers: headers, body: body)
			return
		}
		receiveFrame(commands: FrameResponseKeys.ping.rawValue, headers: headers, body: body)
	}

	///Handle webSocket response
	/// - Parameters:
	///     - response: data, string or error
	private func handleWebSocketResponse(
		frame: WebSocketFrame
	) {
		switch frame {
		case .data(let data):
			guard let string = String(data: data, encoding: .utf8) else {
				stompDelegate?.handle(error: .dataString)
				return
			}
			decode(string: string)
		case .string(let string):
			decode(string: string)
		case .ping, .unknown:
			break
		}
	}

}

extension SwiftStompClient: WebSocketEventsDelegate {
	public func handle(
		event: WebSocketEvents
	) {
		switch event {
		case .connected:
			stompDelegate?.webSocketConnected()
		case .disconnected(let closeCode, let reason):
			stompDelegate?.webSocketDisconnected(closeCode: closeCode, reason: reason)
		case .frame(let frame):
			handleWebSocketResponse(frame: frame)
		case .error(let error):
			stompDelegate?.handle(error: .webSocket(error: error))
		}
	}

}
