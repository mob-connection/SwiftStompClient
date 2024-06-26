# SwiftStompClient

Swift [STOMP](https://stomp.github.io) client for swift via [WebSocketTask](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask) with [Heart-beating](https://stomp.github.io/stomp-specification-1.2.html#Heart-beating)

## Requirements

 - iOS 15.0+
 - macOS 12.0+
 - tvOS 15.0+
 - watchOS 8.0+

## Features

- [x] Heart beat
- [x] Auto Reconnect

## Example using StompClient

```swift

let webSocket: WebSocketService = WebSocketManager(request: URLRequest(url: NetworkConstants.baseSTOMP))
let heartBeat: HeartBeatService = HeartBeatManager(clientHeartBeating: "2000,5000", clientSendingLeeway: 0.0)
let stompClient: SwiftStompClient = .init(webSocket: webSocket, heartBeat: heartBeat)

stompClient.stompDelegate = self
try await stompClient.openWebSocketConnection()
```

## WebSocketService

native webSocket implementation via ```URLSessionWebSocketTask```

## HeartBeatService

optinal service for receiving pong frame from server and sending ping frame to server, initialisation with the string ```clientHeartBeating: 2000,5000``` where ``2000`` (in milliseconds) is the time to send a ping frame to the server ```5000``` is the time to wait for the ping frame to be received from the server, ```clientSendingLeeway``` this is the time we set aside for sending a ping frame, for more information please visit [Heart-beating](https://stomp.github.io/stomp-specification-1.2.html#Heart-beating)

## SwiftStompClient

service that implements [STOMP](https://stomp.github.io)

connect webSocket
```swift
openWebSocketConnection()
```
disconnect webSocket
```swift
disconnectWebSocket(code: Int, reason: Data?)
```
reconnect webSocket
```swift
reconnectWebSocket(nanoseconds: UInt64)
```

send STOMP frames
```swift
sendFrame(frame: StompFrameProtocol)
```

## StompDelegate

```func webSocketConnected()``` 
is called when a webSocket connection is opened

```swift
func receiveStomp(
    frame: SwiftStompClient,
    type: FrameResponseKeys,
    headers: [String : String],
    body: String?
)
```
is called when any frame is received

```swift
func webSocketDisconnected(closeCode: Int, reason: Data?)
```
is called when the webSocket is closed

```swift
func handle(error: SwiftStompError)
```
is called when receive any errors

### For more detail please check ```SwiftStompClientExample```

## Installation

### Swift Package Manager

``` swift
dependencies: [
    .package(url: "https://github.com/mob-connection/SwiftStompClient.git", .upToNextMajor(from: "0.0.8"))
]
````
or (if needed)

```swift
.product(name: "SwiftStompClientDynamic", package: "SwiftStompClient")
```

### CocoaPods

```pod 'SwiftStompClient'```
