import Foundation

public class HeartBeat {
    private var timerPing = DispatchSource.makeTimerSource()
    private var timerPong: DispatchSourceTimer?
    
    private let leeway = DispatchTimeInterval.never

    private var clientHeartBeating: String
    
    private var pingTime: Double = 0.0
    private var pongTime: Double = 0.0
    
    public var pingAction: (() -> Void)?
    public var pongAction: (() -> Void)?
    
    public init(clientHeartBeating: String) {
        self.clientHeartBeating = clientHeartBeating
    }
    
    public func handleFrames(headers: [String : String], frame: SwiftStompClient.FrameResponseKeys) {
        switch frame {
        case .connected where headers.contains(where: { $0.key == HeaderCommands.heartBeat }):
            heartBeating(client: clientHeartBeating, server: headers[HeaderCommands.heartBeat]!)
        case .message:
            resetListeningServerBeating()
        case .receipt:
            resetListeningServerBeating()
        case .ping:
            resetListeningServerBeating()
        default:
            return
        }
    }
    
    public func cancelAllTimers() {
        timerPong?.setEventHandler(handler: nil)
        timerPong?.cancel()
        timerPong = nil
        pongAction = nil
        //
        timerPing.setEventHandler(handler: nil)
        timerPing.cancel()
        pingAction = nil
    }
    
    ///reset timer for sending DISCONNECT stomp frame
    private func resetListeningServerBeating() {
        timerPong?.setEventHandler(handler: nil)
        timerPong?.cancel()
        timerPong = nil
        pongAction = nil
        //
        startListeningServerBeating()
    }
    
    private func startListeningServerBeating() {
        timerPong = DispatchSource.makeTimerSource()
        timerPong?.schedule(deadline: .now() + pongTime, repeating: pongTime, leeway: leeway)
        timerPong?.setEventHandler(handler: pongAction)
        timerPong?.resume()
    }
    
    ///Heart-beart implemetation looks like "5000,5000" were first part in client time beating, second part server time beating(miliseconds)
    /// - Parameters:
    ///     - client: client beating
    ///     - server: server beating
    private func heartBeating(client: String, server: String) {
        var client = String(client)
        var server = String(server)
        
        guard let commaClientIndex = client.firstIndex(of: ","),
            let commaServerIndex = server.firstIndex(of: ",") else {
                print("Seams like doesn't contain comma")
                return
        }
        client.remove(at: commaClientIndex)
        server.remove(at: commaServerIndex)
        
        let cx = Int(client[..<commaClientIndex]) ?? 0
        let cy = Int(client[commaClientIndex...]) ?? 0
        let sx = Int(server[..<commaServerIndex]) ?? 0
        let sy = Int(server[commaServerIndex...]) ?? 0
        
        //in seconds
        pingTime = ceil(Double(max(cx, sy) / 1000))
        pongTime = ceil(Double(max(sx, cy) / 1000))

        if pingTime > 0 {
            timerPing.schedule(deadline: .now(), repeating: pingTime, leeway: leeway)
            timerPing.setEventHandler(handler: pingAction)
            timerPing.activate()
        }
        
        if pongTime > 0 {
            startListeningServerBeating()
        }
    }
}
