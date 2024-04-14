import Foundation

///Basic server frames
public enum FrameResponseKeys: String {
	case connected = "CONNECTED"
	case message = "MESSAGE"
	case receipt = "RECEIPT"
	case error = "ERROR"
	case ping = "\n"

}
