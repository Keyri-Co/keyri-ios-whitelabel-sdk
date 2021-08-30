//
//  Keyri.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 25.08.2021.
//

import Foundation
import Sodium

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

public final class Keyri {
    var id: String?
    var name: String?
    var callbackUrl: URL?
    var logoUrl: URL?
    
    public static let shared = Keyri()
    
    private init() {}
    
    public func initialize(id: String, name: String, callbackUrl: URL, logoUrl: URL) {
        self.id = id
        self.name = name
        self.callbackUrl = callbackUrl
        self.logoUrl = logoUrl
        
        let _ = KeychainService.shared.getCryptoBox()
        
        
        
        let sodium = Sodium()
        let aliceKeyPair = sodium.box.keyPair()!
        let bobKeyPair = sodium.box.keyPair()!
        let message = "My Test Message".bytes
        
        let pk = "0JWazrdDbLA+MwbqHjF9Mmo+3w2oh6IPBrgEFNLUfUw="
        let sk = "EdnAMTx0CvQ/c1fovJbpcJ2KuJwJaFWmjZGGOnTL7oU="
        let pkBytes = [UInt8](Data(base64Encoded: pk)!)
        let skBytes = [UInt8](Data(base64Encoded: sk)!)
        
        let newBobKeyPair = Box.KeyPair(publicKey: pkBytes, secretKey: skBytes)
        

        let encryptedMessageFromAliceToBob: (authenticatedCipherText: Bytes, nonce: Box.Nonce) =
            sodium.box.seal(message: message,
                            recipientPublicKey: newBobKeyPair.publicKey,
                            senderSecretKey: aliceKeyPair.secretKey)!

//        let messageVerifiedAndDecryptedByBob =
//            sodium.box.open(nonceAndAuthenticatedCipherText: encryptedMessageFromAliceToBob,
//                            senderPublicKey: aliceKeyPair.publicKey,
//                            recipientSecretKey: newBobKeyPair.secretKey)
//
//        let res = sodium.utils.bin2base64(messageVerifiedAndDecryptedByBob!)?.fromBase64()
        
        
//        let sodium = Sodium()
//        let aliceKeyPair = sodium.box.keyPair()!
////        let bobKeyPair = sodium.box.keyPair()!
//        let message = "My Test Message".bytes
//
//        let pk = "0JWazrdDbLA+MwbqHjF9Mmo+3w2oh6IPBrgEFNLUfUw="
//        let sk = "EdnAMTx0CvQ/c1fovJbpcJ2KuJwJaFWmjZGGOnTL7oU="
//        let pkBytes = pk.bytes
//        let skBytes = sk.bytes
//
//        let encryptedMessageFromAliceToBob: Bytes =
//            sodium.box.seal(message: message,
//                            recipientPublicKey: pkBytes,
//                            senderSecretKey: aliceKeyPair.secretKey)!
//
//        let messageVerifiedAndDecryptedByBob =
//            sodium.box.open(authenticatedCipherText: "qRrrjrl6/j8rLyHXpZrhzMTMWw==".bytes, senderPublicKey: "SRXk4jMeLk6GC35p3m3+lRsHE7AVDv3YO1CgKNHLyvE=".sodiumBytes(), recipientSecretKey: "0JWazrdDbLA+MwbqHjF9Mmo+3w2oh6IPBrgEFNLUfUw=".sodiumBytes(), nonce: "2p7feALHfdEx0/FoOSSEBFhR8eCTOSZX".sodiumBytes())
        
        print("")
    }
                        
    public func onReadSessionId(_ sessionId: String, completion: @escaping (Result<Session, Error>) -> Void) {
        ApiService.shared.getSession(sessionId: sessionId) { result in
            switch result {
            case .success(let session):
                print(session)
                completion(.success(session))
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    public func signUp(username: String, sessionId: String, service: Service, custom: String?) {
        UserService.shared.signUp(username: username, sessionId: sessionId, service: service, custom: custom)
    }
    
    public func login(sessionId: String, service: Service, account: PublicAccount, custom: String?) {
        UserService.shared.login(sessionId: sessionId, service: service, account: account, custom: custom)
    }
    
    public func mobileLogin(account: PublicAccount, custom: String?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let id = id, let logoUrl = logoUrl, let name = name else {
            return
        }
        UserService.shared.mobileLogin(account: account, service: Service(id: id, name: name, logo: logoUrl.absoluteString), callbackUrl: callbackUrl, custom: custom, completion: completion)
    }
    
    public func mobileSignUp(username: String, custom: String?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let id = id, let logoUrl = logoUrl, let name = name else {
            return
        }
        UserService.shared.mobileSignUp(username: username, service: Service(id: id, name: name, logo: logoUrl.absoluteString), callbackUrl: callbackUrl, custom: custom, completion: completion)
    }
    
    public func accounts() -> [PublicAccount] {
        guard let id = id else {
            return []
        }
        return StorageService.shared.getAllAccounts(serviceId: id).map { PublicAccount(username: $0.username, custom: $0.custom) }
    }
}
