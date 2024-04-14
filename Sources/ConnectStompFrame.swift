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

public struct ConnectStompFrame: StompFrameProtocol {
	public var command: String {
		BasicCommands.connect
	}
	public var headers: [String : String]
	public var body: String?
	public var clientHeartBeat: String?

	///STOMP frame CONNECT with
	/// - Parameters:
	///     - acceptVersion: STOMP version
	///     - login: login
	///     - passcode: passcode
	///     - host: host
	///     - heartBeat: optional value heart-beat
	public init(
		acceptVersion: String,
		login: String,
		passcode: String,
		host: String,
		heartBeat client: String? = nil
	) {
		var connectionHeaders = [HeaderCommands.acceptVersion : acceptVersion,
								 HeaderCommands.login : login,
								 HeaderCommands.passcode : passcode,
								 HeaderCommands.host : host]
		if let clientHeartBeat = client {
			self.clientHeartBeat = clientHeartBeat
			connectionHeaders[HeaderCommands.heartBeat] = clientHeartBeat
		}
		headers = connectionHeaders
	}

	///STOMP frame CONNECT with
	/// - Parameters:
	///     - acceptVersion: accept STOMP version
	///     - heartBeat: optional value heart-beat
	public init(
		acceptVersion: String,
		heartBeat client: String? = nil
	) {
		var connectionHeaders = [HeaderCommands.acceptVersion : acceptVersion]

		if let clientHeartBeat = client {
			self.clientHeartBeat = clientHeartBeat
			connectionHeaders[HeaderCommands.heartBeat] = clientHeartBeat
		}
		headers = connectionHeaders
	}

}
