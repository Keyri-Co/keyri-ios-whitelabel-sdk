//
//  EncryptionUtil.swift
//  CryptoSwift
//
//  Created by Aditya Malladi on 5/16/22.
//

import Foundation
import CryptoKit
import CommonCrypto

public class EncryptionUtil {
    public init() {}
    
    public func deriveKeys(from keyString: String) -> (SharedSecret, P256.KeyAgreement.PublicKey)? {
        guard let data = Data(base64Encoded: keyString) else { return nil }
        do {
            let browserPublic = try P256.KeyAgreement.PublicKey(rawRepresentation: data)
            let mobilePrivateKey = P256.KeyAgreement.PrivateKey()
            let mobilePublicKey = mobilePrivateKey.publicKey
            
            let sharedSecret = try mobilePrivateKey.sharedSecretFromKeyAgreement(with: browserPublic)
            
            return (sharedSecret, mobilePublicKey)
            
        } catch {
            print(error)
            return nil
        }
    }
    
    public func encrypt(message: String, with secret: SharedSecret, salt: String) -> Data? {
        let protocolSalt = salt.data(using: .utf8)!
        let symKey = secret.hkdfDerivedSymmetricKey(using: SHA256.self, salt: protocolSalt, sharedInfo: Data(), outputByteCount: 32)
        
        let msgProtocol = message.data(using: .utf8)!
        do {
            let encrypted = try CryptoKit.AES.GCM.seal(msgProtocol, using: symKey)
            return encrypted.combined
        } catch {
            print(error)
            return nil
        }
    }
    
}
