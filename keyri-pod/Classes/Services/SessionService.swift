//
//  SessionService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation
import SocketIO

struct SessionApproveData: SocketData {
    let cipher: String
    let signature: String
    var publicKey: String?
    let action = "SESSION_VERIFY_APPROVE"
    
    func socketRepresentation() -> SocketData {
        return ["cipher": cipher, "signature": signature, "publicKey": publicKey, "action": action]
    }
}

final class SessionService {
    let keychainService: KeychainService
    let socketService: SocketService
    let encryptionService: EncryptionService
    
    var sessionId: String?
        
    init(keychainService: KeychainService, encryptionService: EncryptionService) {
        self.keychainService = keychainService
        self.socketService = SocketService()
        self.encryptionService = encryptionService
    }
    
    func verifyUserSession(encUserId: String, sessionId: String, custom: String?, usePublicKey: Bool = false, completion: @escaping (Result<Void, Error>) -> Void) {
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
        
        do {
            try keychainService.set(value: userId, forKey: sessionKey)
        } catch {
            completion(.failure(error))
            return
        }
                
        let validateMessage = ValidateMessage(sessionId: sessionId, sessionKey: encSessionKey)
        
        socketService.extraHeaders = ["userSuffix": String(encUserId.prefix(15))]
        socketService.initializeSocket { [weak self] result in
            guard result else {
                completion(.failure(KeyriErrors.keyriSdkError))
                assertionFailure("Socket didn't initialized")
                return
            }
            
            self?.socketService.sendEvent(message: validateMessage) { result in
                guard case let .success(message) = result else {
                    if case let .failure(error) = result {
                        completion(.failure(error))
                        assertionFailure(error.localizedDescription)
                    } else {
                        completion(.failure(KeyriErrors.keyriSdkError))
                        assertionFailure("Socket emition result error")
                    }
                    return
                }
                
                guard
                    let trySessionKey = self?.encryptionService.aesDecrypt(string: message.sessionKey)
                else {
                    completion(.failure(KeyriErrors.keyriSdkError))
                    return
                }
                
                guard let tryUserId = try? self?.keychainService.get(valueForKey: trySessionKey) else {
                    completion(.failure(KeyriErrors.keyriSdkError))
                    assertionFailure("User id for session key not found")
                    return
                }
                
                do {
                    try self?.keychainService.remove(valueForKey: trySessionKey)
                } catch {
                    completion(.failure(error))
                    return
                }
                
                let jsonDict = [
                    "userId": tryUserId,
                    "custom": custom,
                    "timestamp": "\(Date().timeIntervalSince1970)"
                ]
                
                guard let theJSONData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) else {
                    assertionFailure("TODO")
                    return
                }
                
                guard
                    let theJSONText = String(data: theJSONData, encoding: .ascii),
                    let encryptResult = self?.encryptionService.aesEncrypt(string: theJSONText)
                else {
                    assertionFailure("Sodium encrypt fails")
                    return
                }
                var verifyApproveMessage = VerifyApproveMessage(cipher: encryptResult, publicKey: nil, iv: Config().ivAes)
                if usePublicKey {
                    if let publicKey = try? self?.encryptionService.loadPublicKeyString() {
                        verifyApproveMessage.publicKey = publicKey
                    }
                }
                
                self?.socketService.sendEvent(message: verifyApproveMessage) { result in
                    // callback doesn't reaching
                    print(result)
                }
                
                completion(.success(()))
            }
        }
    }
}
