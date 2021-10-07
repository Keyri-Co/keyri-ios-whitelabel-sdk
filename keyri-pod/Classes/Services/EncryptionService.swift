//
//  EncryptionService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation
import Sodium

struct CryptoBox {
    let publicKey: String
    let privateKey: String

    var publicBuffer: [UInt8] {
        let nsData = NSData(base64Encoded: publicKey, options: .ignoreUnknownCharacters)!
        let bytes = [UInt8](nsData as Data)
        return bytes
    }

    var privateBuffer: [UInt8] {
        let nsData = NSData(base64Encoded: privateKey, options: .ignoreUnknownCharacters)!
        let bytes = [UInt8](nsData as Data)
        return bytes
    }
}

final class EncryptionService {
    static let shared = EncryptionService()
    private init() {}
    
    func generateCryproBox() -> CryptoBox {
        let sodium = Sodium()
        let keyPair = sodium.sign.keyPair()!
        let publicKeyString = keyPair.publicKey.base64EncodedString()
        let privateKeyString = keyPair.secretKey.base64EncodedString()
        
        return CryptoBox(publicKey: publicKeyString, privateKey: privateKeyString)
    }
    
    func encryptSodium(string: String, publicKey: String, privateKey: String) -> (authenticatedCipherText: String, nonce: String)? {
        let stringBytes = string.bytes
        let sodium = Sodium()
        
        let publicKeyBytes = [UInt8](Data(base64Encoded: publicKey)!)
        let privateKeyBytes = [UInt8](Data(base64Encoded: privateKey)!)
                
        guard
            let sealResult: (authenticatedCipherText: Bytes, nonce: Box.Nonce) = sodium.box.seal(message: stringBytes, recipientPublicKey: publicKeyBytes, senderSecretKey: privateKeyBytes)
        else {
            return nil
        }
        
        return (authenticatedCipherText: sealResult.authenticatedCipherText.base64EncodedString(), nonce: sealResult.nonce.base64EncodedString())
    }
    
    func encryptSeal(string: String, publicKey: String) -> String? {
        let stringBytes = string.bytes
        let sodium = Sodium()
        
        let publicKeyBytes = [UInt8](Data(base64Encoded: publicKey)!)
        
        let sealResult = sodium.box.seal(message: stringBytes, recipientPublicKey: publicKeyBytes)
        
        return sealResult?.base64EncodedString()
    }
    
    func createSignature(string: String, privateKey: String) -> String? {
        let stringBytes = string.bytes
        let sodium = Sodium()
        
        let privateKeyBytes = [UInt8](Data(base64Encoded: privateKey)!)
        
        let signature = sodium.sign.signature(message: stringBytes, secretKey: privateKeyBytes)
        
        return signature?.base64EncodedString()
    }
}

extension Bytes {
    func base64EncodedString() -> String {
        Data(self).base64EncodedString()
    }
}
