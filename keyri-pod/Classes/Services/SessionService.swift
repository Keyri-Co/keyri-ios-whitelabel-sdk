//
//  SessionService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation

final class SessionService {
    let keychainService: KeychainService
    let socketService: SocketService
    let encryptionService: EncryptionService
    
    var sessionId: String?
    
    private var encSessionKey: String?
    private var completion: ((Result<Void, Error>) -> Void)?
        
    init(keychainService: KeychainService, encryptionService: EncryptionService) {
        self.keychainService = keychainService
        self.socketService = SocketService()
        self.encryptionService = encryptionService
        
        socketService.delegate = self
    }
    
    func verifyUserSession(encUserId: String, sessionId: String, custom: String?, usePublicKey: Bool = false, completion: @escaping (Result<Void, Error>) -> Void) {
        self.sessionId = sessionId
        self.completion = completion
        guard
            let userId = encryptionService.aesDecrypt(string: encUserId)
        else {
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }

        let sessionKey = String.random(length: 32)
        guard
            let encSessionKey = encryptionService.aesEncrypt(string: sessionKey)
        else {
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }
        
        self.encSessionKey = encSessionKey
        
        do {
            try keychainService.set(value: userId, forKey: sessionKey)
        } catch {
            completion(.failure(error))
            return
        }
        
        socketService.extraHeaders = ["userSuffix": String(encUserId.prefix(15))]
        socketService.initializeSocket()
    }
    
    private func sessionVerifyRequest(message: VerifyRequestMessage) {
        guard
            let trySessionKey = encryptionService.aesDecrypt(string: message.sessionKey)
        else {
            completion?(.failure(KeyriErrors.keyriSdkError))
            return
        }

        guard let tryUserId = try? keychainService.get(valueForKey: trySessionKey) else {
            completion?(.failure(KeyriErrors.keyriSdkError))
            Assertion.failure("User id for session key not found")
            return
        }

        do {
            try keychainService.remove(valueForKey: trySessionKey)
        } catch {
            completion?(.failure(error))
            return
        }

        let jsonDict = [
            "userId": tryUserId,
            "custom": "custom",
            "timestamp": "\(Date().timeIntervalSince1970)"
        ]

        guard let theJSONData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) else {
            Assertion.failure("TODO")
            return
        }

        guard
            let theJSONText = String(data: theJSONData, encoding: .ascii),
            let encryptResult = self.encryptionService.aesEncrypt(string: theJSONText)
        else {
            Assertion.failure("Sodium encrypt fails")
            return
        }
        var verifyApproveMessage = VerifyApproveMessage(cipher: encryptResult, publicKey: nil, iv: self.encryptionService.getIV())
        if true {
            if let publicKey = try? self.encryptionService.loadPublicKeyString() {
                verifyApproveMessage.publicKey = publicKey
            }
        }
        
        socketService.sendEvent(message: verifyApproveMessage)
    }
}

extension SessionService: SocketServiceDelegate {
    func socketServiceDidConnected() {
        let validateMessage = ValidateMessage(sessionId: sessionId!, sessionKey: encSessionKey!)
        socketService.sendEvent(message: validateMessage)
    }
    
    func socketServiceDidConnectionFails() {
        completion?(.failure(KeyriErrors.networkError))
    }
    
    func socketServiceDidDisconnected() {
        completion?(.failure(KeyriErrors.networkError))
    }
    
    func socketServiceDidReceiveEvent(event: Result<VerifyRequestMessage, Error>) {
        switch event {
        case .success(let message):
            if message.action == .SESSION_VERIFY_REQUEST {
                sessionVerifyRequest(message: message)
            }
        case .failure(let error):
            completion?(.failure(error))
        }
    }
}
