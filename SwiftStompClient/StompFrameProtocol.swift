public protocol StompFrameProtocol {
	var command: String { get }
	var headers: [String: String] { get set }
	var body: String? { get set }

}
