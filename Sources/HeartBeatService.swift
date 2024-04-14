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

import Foundation

public enum HeartBeatError: Error, CustomStringConvertible {
	case noClientComma
	case noServerComma
	case cantClientConvert
	case cantServerConvert

	public var description: String {
		switch self {
		case .noClientComma:
			"No client comma"
		case .noServerComma:
			"No server comma"
		case .cantClientConvert:
			"Can not convert client string to `Double`"
		case .cantServerConvert:
			"Can not convert server string to `Double`"
		}
	}

}

public protocol HeartBeatService {
	var pingAction: (() -> Void)? { get set }
	var pongAction: (() -> Void)? { get set }
	var errorAction: ((HeartBeatError) -> Void)? { get set }
	init(clientHeartBeating: String, clientSendingLeeway: Double)
	func handler(headers: [String : String], frame: FrameResponseKeys)
	func cancelAllTimers()

}

public class HeartBeatManager: HeartBeatService {
	private var timerPing: DispatchSourceTimer?
	private var timerPong: DispatchSourceTimer?
	private let leeway: DispatchTimeInterval = .never
	private let clientHeartBeating: String
	private var pingTime: Double = 0.0
	private var pongTime: Double = 0.0
	private let queue = DispatchQueue(label: "heart.beat.manager.queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .workItem)

	public var pingAction: (() -> Void)?
	public var pongAction: (() -> Void)?
	public var errorAction: ((HeartBeatError) -> Void)?

	///Client leeway sending ping frame
	public let clientSendingLeeway: Double

	///Heart beat
	/// - Parameters:
	///     - clientHeartBeating: Representation like "5000,5000" are the first part of the client time (milliseconds), the second part of the server time (milliseconds)
	///     - clientSendingLeeway: This is the time we set aside for sending a ping frame
	public required init(
		clientHeartBeating: String,
		clientSendingLeeway: Double = 0.0
	) {
		self.clientHeartBeating = clientHeartBeating
		self.clientSendingLeeway = clientSendingLeeway
	}

	public func handler(
		headers: [String : String],
		frame: FrameResponseKeys
	) {
		switch frame {
		case .connected where headers.contains(where: { $0.key == HeaderCommands.heartBeat }):
			heartBeating(client: clientHeartBeating, server: headers[HeaderCommands.heartBeat]!)
		case .message, .receipt, .ping:
			resetListeningServerBeating()
		default:
			break
		}
	}

	///Cancelation all timers
	public func cancelAllTimers() {
		pingAction = nil
		timerPing?.setEventHandler(handler: nil)
		timerPing?.cancel()
		timerPing = nil

		pongAction = nil
		timerPong?.setEventHandler(handler: nil)
		timerPong?.cancel()
		timerPong = nil
	}

	///Heart-beart implemetation looks like "5000,5000" were first part in client time beating (miliseconds), second part server time beating (miliseconds)
	/// - Parameters:
	///     - client: client beating
	///     - server: server beating
	private func heartBeating(
		client: String,
		server: String
	) {
		var client = String(client)
		var server = String(server)

		guard let commaClientIndex = client.firstIndex(of: ",") else {
			errorAction?(HeartBeatError.noClientComma)
			return
		}
		client.remove(at: commaClientIndex)

		guard let commaServerIndex = server.firstIndex(of: ",") else {
			errorAction?(HeartBeatError.noServerComma)
			return
		}
		server.remove(at: commaServerIndex)

		guard let cx = Double(client[..<commaClientIndex]),
			  let cy = Double(client[commaClientIndex...])
		else {
			errorAction?(HeartBeatError.cantClientConvert)
			return
		}

		guard let sx = Double(server[..<commaServerIndex]),
			  let sy = Double(server[commaServerIndex...])
		else {
			errorAction?(HeartBeatError.cantServerConvert)
			return
		}

		//pong time in seconds
		pongTime = max(sx, cy) / 1000

		//ping time
		let clientPing = max(cx, sy)

		assert(clientSendingLeeway < clientPing, "Unable to set `clientSendingLeeway` greater than `clientPing`")

		//add client time leeway
		pingTime = (clientPing - clientSendingLeeway) / 1000

		if pingTime > 0 {
			timerPing = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
			timerPing?.schedule(deadline: .now(), repeating: pingTime, leeway: leeway)
			timerPing?.setEventHandler(handler: pingAction)
			timerPing?.resume()
		}

		if pongTime > 0 {
			startListeningServerBeating()
		}
	}

	///Resetting the timer to send a DISCONNECT stomp frame
	private func resetListeningServerBeating() {
		timerPong?.setEventHandler(handler: nil)
		timerPong?.cancel()
		timerPong = nil
		startListeningServerBeating()
	}

	private func startListeningServerBeating() {
		timerPong = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
		timerPong?.schedule(deadline: .now() + pongTime, repeating: pongTime, leeway: leeway)
		timerPong?.setEventHandler(handler: { [weak self] in
			self?.pongAction?()
			self?.cancelAllTimers()
		})
		timerPong?.resume()
	}

}
