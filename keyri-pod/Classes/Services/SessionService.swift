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
    
    func verifyUserSession(encUserId: String, sessionId: String, rpPublicKey: String?, custom: String?, usePublicKey: Bool = false, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let box = try? keychainService.getCryptoBox() else {
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }
        
        guard
            let userIdData = AES.decryptionAESModeECB(messageData: encUserId.data(using: .utf8), key: box.privateKey),
            let userId = String(data: userIdData, encoding: .utf8)
        else {
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }

        let sessionKey = String.random(length: 32)
        guard
            let encSessionKeyData = AES.encryptionAESModeECB(messageData: sessionKey.data(using: .utf8), key: box.privateKey),
            let encSessionKey = String(data: encSessionKeyData, encoding: .utf8)
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
                
        let payload = Payload(sessionId: sessionId, sessionKey: encSessionKey)
        
        socketService.extraHeaders = ["userSuffix": String(encUserId.prefix(15))]

        socketService.initializeSocket { [weak self] result in
            guard result else {
                completion(.failure(KeyriErrors.keyriSdkError))
                assertionFailure("Socket didn't initialized")
                return
            }
            
            self?.socketService.emit(event: "SESSION_VALIDATE", data: payload) { result in
                guard
                    case let .success(dict) = result,
                    let publicKey = rpPublicKey ?? dict["publicKey"],
                    let sessionKey = dict["sessionKey"]
                else {
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
                    let sessionKeyData = AES.decryptionAESModeECB(messageData: sessionKey.data(using: .utf8), key: box.privateKey),
                    let trySessionKey = String(data: sessionKeyData, encoding: .utf8)
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
                    let encryptResult = self?.encryptionService.encryptSeal(string: theJSONText, publicKey: publicKey)
                else {
                    assertionFailure("Sodium encrypt fails")
                    return
                }
                guard let signature = self?.encryptionService.createSignature(string: theJSONText, privateKey: box.privateKey) else {
                    assertionFailure("Create signature fails")
                    return
                }
                
                var sessionApproveData = SessionApproveData(cipher: encryptResult, signature: signature, publicKey: nil)
                if usePublicKey {
                    sessionApproveData.publicKey = box.publicBuffer?.base64EncodedString()
                }
                
                self?.socketService.emit(event: "message", data: sessionApproveData) { result in
                    // callback doesn't reaching
                    print(result)
                }
                
                completion(.success(()))
            }
        }
    }
}
