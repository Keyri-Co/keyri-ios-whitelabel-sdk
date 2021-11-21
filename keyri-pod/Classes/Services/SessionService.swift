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
    static let shared = SessionService()
    private init() {}
    
    var sessionId: String?
    
    func verifyUserSession(encUserId: String, sessionId: String, rpPublicKey: String?, custom: String?, usePublicKey: Bool = false, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let box = KeychainService.shared.getCryptoBox() else {
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
        
        KeychainService.shared.set(value: userId, forKey: sessionKey)
                
        let payload = Payload(sessionId: sessionId, sessionKey: encSessionKey)
        
        SocketService.shared.extraHeaders = ["userSuffix": String(encUserId.prefix(15))]

        SocketService.shared.initializeSocket { result in
            guard result else {
                completion(.failure(KeyriErrors.keyriSdkError))
                assertionFailure("Socket didn't initialized")
                return
            }
            
            SocketService.shared.emit(event: "SESSION_VALIDATE", data: payload) { result in
                guard
                    let publicKey = rpPublicKey ?? result["publicKey"],
                    let sessionKey = result["sessionKey"]
                else {
                    completion(.failure(KeyriErrors.keyriSdkError))
                    assertionFailure("Socket emition result error")
                    return
                }
                
                guard
                    let sessionKeyData = AES.decryptionAESModeECB(messageData: sessionKey.data(using: .utf8), key: box.privateKey),
                    let trySessionKey = String(data: sessionKeyData, encoding: .utf8)
                else {
                    completion(.failure(KeyriErrors.keyriSdkError))
                    return
                }
                
                guard let tryUserId = KeychainService.shared.get(valueForKey: trySessionKey) else {
                    completion(.failure(KeyriErrors.keyriSdkError))
                    assertionFailure("User id for session key not found")
                    return
                }
                
                let jsonDict = [
                    "userId": tryUserId,
                    "custom": custom,
                    "timestamp": "\(Date().timeIntervalSince1970)"
                ]
                
                guard let theJSONData = try? JSONSerialization.data( withJSONObject: jsonDict, options: []) else {
                    assertionFailure("TODO")
                    return
                }
                
                guard
                    let theJSONText = String(data: theJSONData, encoding: .ascii),
                    let encryptResult = EncryptionService.shared.encryptSeal(string: theJSONText, publicKey: publicKey)
                else {
                    assertionFailure("Sodium encrypt fails")
                    return
                }
                guard let signature = EncryptionService.shared.createSignature(string: theJSONText, privateKey: box.privateKey) else {
                    assertionFailure("Create signature fails")
                    return
                }
                
                var sessionApproveData = SessionApproveData(cipher: encryptResult, signature: signature, publicKey: nil)
                if usePublicKey {
                    sessionApproveData.publicKey = box.publicBuffer?.base64EncodedString()
                }
                
                SocketService.shared.emit(event: "message", data: sessionApproveData) { result in
                    // callback doesn't reaching
                    print(result)
                }
                
                completion(.success(()))
            }
        }
    }
}
