//
//  SocketService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation

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

protocol SocketServiceDelegate: AnyObject {
    func socketServiceDidConnected()
    func socketServiceDidConnectionFails()
    func socketServiceDidDisconnected()
    func socketServiceDidReceiveEvent(event: Result<VerifyRequestMessage, Error>)
}

final class SocketService: WebSocketDelegate {    
    var extraHeaders: [String : String]?
    var isConnected = false
    weak var delegate: SocketServiceDelegate?

    private let socketUrl: String
    private var socket: WebSocket?
    
    init() {
        let config = Config()
        socketUrl = config.wsUrl
    }
    
    func initializeSocket() {
        guard let socketUrl = URL(string: self.socketUrl) else {
            assertionFailure("Invalid socket url config")
            delegate?.socketServiceDidConnectionFails()
            return
        }

        var request = URLRequest(url: socketUrl)
        request.timeoutInterval = 5
        for (key, value) in extraHeaders ?? [:] {
            request.addValue(value, forHTTPHeaderField: key)
        }
        socket = WebSocket(request: request)
        socket?.delegate = self
                        
        socket?.connect()
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            self.isConnected = true
            print("websocket is connected: \(headers)")
            delegate?.socketServiceDidConnected()
        case .disconnected(let reason, let code):
            self.isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
            delegate?.socketServiceDidDisconnected()
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
            delegate?.socketServiceDidDisconnected()
        case .error(let error):
            self.isConnected = false
            self.handleError(error)
            delegate?.socketServiceDidDisconnected()
        default:
            break
        }
    }
    
    func sendEvent(message: SocketRepresentation) {
        guard let messageString = message.socketRepresentation() else {
            return
        }
        print(messageString)
        socket?.write(string: messageString)
    }

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
            delegate?.socketServiceDidReceiveEvent(event: .success(message))
        }
    }
}
