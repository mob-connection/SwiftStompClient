///Basic client frames
public struct BasicCommands {
    static let connect = "CONNECT"
    static let send = "SEND"
    static let subscribe = "SUBSCRIBE"
    static let unsubscribe = "UNSUBSCRIBE"
    static let begin = "BEGIN"
    static let commit = "COMMIT"
    static let abort = "ABORT"
    static let ack = "ACK"
    static let disconnect = "DISCONNECT"
    static let ping = "\n"

    static let controlChar = "\u{0000}"
}
