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
