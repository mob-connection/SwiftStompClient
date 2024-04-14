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

///Basic client frames
public enum BasicCommands {
	public static let connect = "CONNECT"
	public static let send = "SEND"
	public static let subscribe = "SUBSCRIBE"
	public static let unsubscribe = "UNSUBSCRIBE"
	public static let begin = "BEGIN"
	public static let commit = "COMMIT"
	public static let abort = "ABORT"
	public static let ack = "ACK"
	public static let disconnect = "DISCONNECT"
	public static let ping = "\n"
	public static let controlChar = "\u{0000}"

}
