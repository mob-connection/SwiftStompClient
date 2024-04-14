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

public struct SendStompFrame: StompFrameProtocol {
	public var command: String {
		BasicCommands.send
	}
	public var headers: [String : String]
	public var body: String?

	///STOMP frame SEND with
	/// - Parameters:
	///     - body: string body
	///     - destination: destination
	///     - headers: optional headers
	///     - transaction: transaction
	public init(
		body: String,
		destination: String,
		headers: [String : String]?,
		transaction: String?
	) {
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
