//
//  SocketService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation
import SocketIO
import Starscream

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


final class SocketService2: WebSocketDelegate {
    typealias SocketEventCompletion = (Result<VerifyRequestMessage, Error>) -> Void
    
    var extraHeaders: [String : String]?

    private let socketUrl: String
    private var socket: WebSocket?
    private var completion: (SocketEventCompletion)?
    var isConnected = false
    
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

        var request = URLRequest(url: socketUrl) //https://localhost:8080
        request.timeoutInterval = 5
        for (key, value) in extraHeaders ?? [:] {
            request.addValue(value, forHTTPHeaderField: key)
        }
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    func sendEvent(message: SocketRepresentation, completion: @escaping SocketEventCompletion) {
        self.completion = completion
//        socket?.emit(event, data)
        guard let messageString = message.socketRepresentation() else {
            completion(.failure(KeyriErrors.networkError))
            return
        }
        socket?.write(string: messageString)
    }

    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
            completion?(.failure(KeyriErrors.networkError))
        case .text(let string):
            print("Received text: \(string)")
            if let data = string.data(using: .utf8) {
                parseVerificationRequest(data: data)
            }
        case .binary(let data):
            print("Received data: \(data.count)")
            parseVerificationRequest(data: data)
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
            completion?(.failure(KeyriErrors.networkError))
        case .error(let error):
            isConnected = false
            handleError(error)
            completion?(.failure(KeyriErrors.networkError))
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
    
    private func parseVerificationRequest(data: Data) {
        let message = try? JSONDecoder().decode(VerifyRequestMessage.self, from: data)
        if let message = message, message.action == .SESSION_VERIFY_REQUEST {
            completion?(.success(message))
        }
    }
}

enum SocketAction: String, Codable {
    case SESSION_VALIDATE
    case SESSION_VERIFY_REQUEST
    case SESSION_VERIFY_APPROVE
}

protocol SocketRepresentation {
    func socketRepresentation() -> String?
}

struct ValidateMessage: SocketRepresentation, Codable {
    var action: String = SocketAction.SESSION_VALIDATE.rawValue
    let sessionId: String
    let sessionKey: String

    func socketRepresentation() -> String? {
//        return ["action": action, "sessionId": sessionId, "sessionKey": sessionKey]
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        let jsonString = String(data: jsonData, encoding: .utf8)
        return jsonString
    }
}

struct VerifyApproveMessage: SocketRepresentation, Codable {
    let cipher: String
    let signature: String
    var publicKey: String?
    var action = SocketAction.SESSION_VERIFY_APPROVE.rawValue
    
    func socketRepresentation() -> String? {
//        return ["cipher": cipher, "signature": signature, "publicKey": publicKey, "action": action]
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        let jsonString = String(data: jsonData, encoding: .utf8)
        return jsonString
    }
}

struct VerifyRequestMessage: Codable {
    let action: SocketAction
    let publicKey: String?
    let sessionKey: String
}
