//
//  SocketService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation
import SocketIO
import Starscream

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
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        let jsonString = String(data: jsonData, encoding: .utf8)
        return jsonString
    }
}

struct VerifyApproveMessage: SocketRepresentation, Codable {
    let cipher: String
    var publicKey: String?
    var action = SocketAction.SESSION_VERIFY_APPROVE.rawValue
    var iv: String
    
    func socketRepresentation() -> String? {
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

final class SocketService {
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

        var request = URLRequest(url: socketUrl)
        request.timeoutInterval = 5
        for (key, value) in extraHeaders ?? [:] {
            request.addValue(value, forHTTPHeaderField: key)
        }
        socket = WebSocket(request: request)
        
        socket?.onEvent = { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .connected(let headers):
                self.isConnected = true
                print("websocket is connected: \(headers)")
                completion(true)
            case .disconnected(let reason, let code):
                self.isConnected = false
                print("websocket is disconnected: \(reason) with code: \(code)")
                self.completion?(.failure(KeyriErrors.networkError))
            case .text(let string):
                print("Received text: \(string)")
                if let data = string.data(using: .utf8) {
                    self.parseVerificationRequest(data: data)
                }
            case .binary(let data):
                print("Received data: \(data.count)")
                self.parseVerificationRequest(data: data)
            case .cancelled:
                self.isConnected = false
                self.completion?(.failure(KeyriErrors.networkError))
            case .error(let error):
                self.isConnected = false
                self.handleError(error)
                self.completion?(.failure(KeyriErrors.networkError))
            default:
                break
            }
        }
        socket?.connect()
    }
    
    func sendEvent(message: SocketRepresentation, completion: @escaping SocketEventCompletion) {
        self.completion = completion
        guard let messageString = message.socketRepresentation() else {
            completion(.failure(KeyriErrors.networkError))
            return
        }
        print(messageString)
        socket?.write(string: messageString)
    }
}

extension SocketService {
    private func handleError(_ error: Error?) {
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
