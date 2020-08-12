# SwiftStompClient
---
StompClien it's implementation [STOMP](https://stomp.github.io) on native [WebSocket](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask) started support from iOS 13

## Requirements
---
 - iOS 13.0+
 - macOS 10.15+
 - Mac Catalyst 13.0+
 - tvOS 13.0+
 - watchOS 6.0+
 
## Example using StompClient
---
```swift
let request = URLRequest(url: "wss://,ws://")
let webSocket = WebSocket(request: request)
let heartBeat = HeartBeat(clientHeartBeating: "2000,5000")
let stompClient = SwiftStompClient(webSocket: webSocket, heartBeat: heartBeat)

stompClient.stompDelegate = self
stompClient.openWebSocketConnection()
```

```request``` request must contain ws:// or wss://

```webSocket``` webSocket connection for sending STOMP frames

```heartBeat``` heartBeat optinal parameter for reciving pong frame and sending ping frame, init with string "2000,5000" where 2000 (in milliseconds) time to sending ping frame to server, 5000 wating handling pong frame from server, for more detail visit [Heart-beating](https://stomp.github.io/stomp-specification-1.2.html#Heart-beating)

```stompDelegate``` implement handling webSocket connection/disconnection, resiving frames ```CONNECTED, MESSAGE, RECEIPT, ERROR, \n```

```openWebSocketConnection()``` open webSocket connection, handle opening webSocket ```func handleWebSocketConnect(session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol: String?)``` then you can use ```sendFrame(frame: StompFrameProtocol)```

```closeWebSocketConnection()``` disconnect webSocket connection, handle disconnect webSocket ```func handleWebSocketDisconnect(session: URLSession, webSocketTask: URLSessionWebSocketTask, closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)```

```sendFrame(frame: StompFrameProtocol)``` send STOMP frame via websocket, for sending custom frame (if needed) just subsribe object to `StompFrameProtocol`

## Installation
### CocoaPods
`
pod 'SwiftStompClient', '~> 0.0.2'
`
