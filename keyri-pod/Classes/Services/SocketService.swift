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
    typealias SocketEventCompletion = (Result<[String: String], Error>) -> Void
    
    var extraHeaders: [String : String]?
    
    private let socketUrl: String
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    private var completion: (SocketEventCompletion)?
    
    init() {
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
        socket?.on(clientEvent: .connect) { (data, ack) in
            print("socket connected")
            completion(true)
        }
        
        socket?.on("SESSION_VERIFY_REQUEST") { [weak self] data, ack in
            print("socket SESSION_VERIFY_REQUEST")
            guard
                let array = data as? [[String: String]],
                let dict = array.first,
                dict["action"] == "SESSION_VERIFY_REQUEST"
            else {
                self?.completion?(.failure(KeyriErrors.networkError))
                assertionFailure("SESSION_VERIFY_REQUEST data error")
                return
            }
            self?.completion?(.success(dict))
        }
                
        socket?.on("disconnect") { [weak self] data, ack in
            self?.completion?(.failure(KeyriErrors.networkError))
        }
        
        socket?.on("connect_error") { [weak self] data, ack in
            self?.completion?(.failure(KeyriErrors.networkError))
        }
                
        socket?.connect()
    }
    
    func emit(event: String, data: SocketData, completion: @escaping SocketEventCompletion) {
        self.completion = completion
        socket?.emit(event, data)
    }
    
    func disconnectSocket() {
        socket?.removeAllHandlers()
        socket?.disconnect()
        print("socket Disconnected")
    }
}
