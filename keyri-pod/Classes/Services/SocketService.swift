//
//  SocketService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation
import SocketIO

struct Payload: SocketData {
    let action: String = "SESSION_VALIDATE"
    let sessionId: String
    let sessionKey: String

    func socketRepresentation() -> SocketData {
        return ["action": action, "sessionId": sessionId, "sessionKey": sessionKey]
    }
}

final class SocketService {
    typealias SocketEventCompletion = ([String: String]) -> Void
    
    static let shared = SocketService()
    
    var extraHeaders: [String : String]?
    
    private let socketUrl: String
    private var manager: SocketManager?
    private var socket: SocketIOClient!
    private var completion: (SocketEventCompletion)?
    
    private init() {
        let config = Config()
        socketUrl = config.wsUrl
    }
    
    func initializeSocket(completion: @escaping (Bool) -> Void) {
        guard let socketUrl = URL(string: self.socketUrl) else {
            assertionFailure("Invalid socket url config")
            completion(false)
            return
        }
        
        var config: SocketIOClientConfiguration = [.log(true), .compress, .forceWebsockets(true)]
        if let extraHeaders = extraHeaders {
            config.insert(.extraHeaders(extraHeaders))
        }
        manager = SocketManager(socketURL: socketUrl, config: config)
        socket = manager?.defaultSocket
                        
        disconnectSocket()
        socket.on(clientEvent: .connect) { (data, ack) in
            print("socket connected")
            completion(true)
        }
        
        socket.on("SESSION_VERIFY_REQUEST") { [weak self] data, ack in
            print("socket SESSION_VERIFY_REQUEST")
            guard
                let array = data as? [[String: String]],
                let dict = array.first,
                dict["action"] == "SESSION_VERIFY_REQUEST"
            else {
                self?.completion?([:])
                assertionFailure("SESSION_VERIFY_REQUEST data error")
                return
            }
            self?.completion?(dict)
        }
        
        socket.on("disconnect") { data, ack in
        }
                
        socket.connect()
    }
    
    func emit(event: String, data: SocketData, completion: @escaping SocketEventCompletion) {
        self.completion = completion
        socket.emit(event, data)
    }
    
    func disconnectSocket() {
        socket.removeAllHandlers()
        socket.disconnect()
        print("socket Disconnected")
    }
}
