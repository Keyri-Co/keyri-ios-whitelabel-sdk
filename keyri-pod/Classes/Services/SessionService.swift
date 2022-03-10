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
    private var verifyUserSessionCustom: String?
    private var isWhitelabelAuth = false
    
    private var completion: ((Result<Void, Error>) -> Void)?
        
    init(keychainService: KeychainService, encryptionService: EncryptionService) {
        self.keychainService = keychainService
        self.socketService = SocketService()
        self.encryptionService = encryptionService
        
        socketService.delegate = self
    }
    
    func verifyUserSession(encUserId: String, sessionId: String, custom: String?, usePublicKey: Bool = false, completion: @escaping (Result<Void, Error>) -> Void) {
        self.sessionId = sessionId
        self.verifyUserSessionCustom = custom
        self.isWhitelabelAuth = false
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
    
    private func sessionVerifyRequest(message: VerifyRequestMessage, custom: String?) {
        var jsonDict = [
            "timestamp": "\(Date().timeIntervalSince1970)"
        ]
        if let userId = retreiveUserId(sessionKey: message.sessionKey) {
            jsonDict["userId"] = userId
        }
        if let custom = verifyUserSessionCustom {
            jsonDict["custom"] = custom
        }

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
        completion?(.success(()))
        completion = nil
    }
    
    private func retreiveUserId(sessionKey: String) -> String? {
        guard !isWhitelabelAuth else { return nil }
        guard let trySessionKey = encryptionService.aesDecrypt(string: sessionKey) else {
            return nil
        }

        guard let tryUserId = try? keychainService.get(valueForKey: trySessionKey) else {
            Assertion.failure("User id for session key not found")
            return nil
        }

        do {
            try keychainService.remove(valueForKey: trySessionKey)
        } catch {
            return nil
        }
        
        return tryUserId
    }
    
    func whitelabelAuth(sessionId: String, custom: String, completion: @escaping (Result<Void, Error>) -> Void) {
        self.sessionId = sessionId
        self.verifyUserSessionCustom = custom
        self.isWhitelabelAuth = true
        self.completion = completion
        
        let sessionKey = String.random(length: 32)
        guard
            let encSessionKey = encryptionService.aesEncrypt(string: sessionKey)
        else {
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }
        
        self.encSessionKey = encSessionKey
        
        socketService.initializeSocket()
    }
}

extension SessionService: SocketServiceDelegate {
    func socketServiceDidConnected() {
        guard let sessionId = sessionId, let encSessionKey = encSessionKey else {
            Assertion.failure("sessionId and encSessionKey should not be nil")
            return
        }
        let validateMessage = ValidateMessage(sessionId: sessionId, sessionKey: encSessionKey)
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
                sessionVerifyRequest(message: message, custom: verifyUserSessionCustom)
            }
        case .failure(let error):
            completion?(.failure(error))
        }
    }
}
