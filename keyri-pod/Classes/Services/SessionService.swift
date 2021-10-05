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
    let nonce: String
    let publicKey: String
    let action = "SESSION_VERIFY_APPROVE"
    
    func socketRepresentation() -> SocketData {
        return ["cipher": cipher, "nonce": nonce, "publicKey": publicKey, "action": action]
    }
}

final class SessionService {
    static let shared = SessionService()
    private init() {}
    
    var sessionId: String?
    
    func verifyUserSession(encUserId: String, sessionId: String, rpPublicKey: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        let box = KeychainService.shared.getCryptoBox()
        
        let userIdData = AES.decryptionAESModeECB(messageData: encUserId.data(using: .utf8)!, key: box.privateKey)!
        let userId = String(data: userIdData, encoding: .utf8)!

        let sessionKey = String.random(length: 32)
        let encSessionKeyData = AES.encryptionAESModeECB(messageData: sessionKey.data(using: .utf8)!, key: box.privateKey)!
        let encSessionKey = String(data: encSessionKeyData, encoding: .utf8)!
        
        KeychainService.shared.set(value: userId, forKey: sessionKey)
                
        let payload = Payload(sessionId: sessionId, sessionKey: encSessionKey)
        
        SocketService.shared.extraHeaders = ["userSuffix": String(encUserId.prefix(15))]

        SocketService.shared.initializeSocket { result in
            guard result else {
                completion(.failure(KeyriErrors.socketInitializationFails))
                assertionFailure("Socket didn't initialized")
                return
            }
            
            SocketService.shared.emit(event: "SESSION_VALIDATE", data: payload) { result in
                guard
                    let publicKey = result["publicKey"],
                    let sessionKey = result["sessionKey"]
                else {
                    completion(.failure(KeyriErrors.socketEmitionFails))
                    assertionFailure("Socket emition result error")
                    return
                }
                
                let sessionKeyData = AES.decryptionAESModeECB(messageData: sessionKey.data(using: .utf8)!, key: box.privateKey)!
                let trySessionKey = String(data: sessionKeyData, encoding: .utf8)!
                
                guard let tryUserId = KeychainService.shared.get(valueForKey: trySessionKey) else {
                    completion(.failure(KeyriErrors.generic))
                    assertionFailure("User id for session key not found")
                    return
                }
                                
                guard let encryptResult = EncryptionService.shared.encryptSodium(string: tryUserId, publicKey: rpPublicKey ?? publicKey, privateKey: box.privateBuffer.base64EncodedString()) else {
                    completion(.failure(KeyriErrors.generic))
                    assertionFailure("Sodium encrypt fails")
                    return
                }
                
                let sessionApproveData = SessionApproveData(cipher: encryptResult.authenticatedCipherText, nonce: encryptResult.nonce, publicKey: box.publicBuffer.base64EncodedString())
                
                SocketService.shared.emit(event: "message", data: sessionApproveData) { result in
                    // callback doesn't reaching
                    print(result)
                }
                
                completion(.success(()))
            }
        }
    }
}
