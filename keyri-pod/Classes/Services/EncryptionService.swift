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

    var publicBuffer: [UInt8]? {
        guard let nsData = NSData(base64Encoded: publicKey, options: .ignoreUnknownCharacters) else {
            return nil
        }
        let bytes = [UInt8](nsData as Data)
        return bytes
    }
}

final class EncryptionService {
    static let shared = EncryptionService()
    private init() {}
    
    func generateCryproBox() -> CryptoBox? {
        let sodium = Sodium()
        guard let keyPair = sodium.sign.keyPair() else {
            return nil
        }
        let publicKeyString = keyPair.publicKey.base64EncodedString()
        let privateKeyString = keyPair.secretKey.base64EncodedString()
        
        return CryptoBox(publicKey: publicKeyString, privateKey: privateKeyString)
    }
    
    func encryptSodium(string: String, publicKey: String, privateKey: String) -> (authenticatedCipherText: String, nonce: String)? {
        let stringBytes = string.bytes
        let sodium = Sodium()
                
        guard
            let publicKeyBytes = publicKey.base64EncodedData(),
            let privateKeyBytes = privateKey.base64EncodedData(),
            let sealResult: (authenticatedCipherText: Bytes, nonce: Box.Nonce) = sodium.box.seal(message: stringBytes, recipientPublicKey: publicKeyBytes, senderSecretKey: privateKeyBytes)
        else {
            return nil
        }
        
        return (authenticatedCipherText: sealResult.authenticatedCipherText.base64EncodedString(), nonce: sealResult.nonce.base64EncodedString())
    }
    
    func encryptSeal(string: String, publicKey: String) -> String? {
        let stringBytes = string.bytes
        let sodium = Sodium()
        
        guard let publicKeyBytes = publicKey.base64EncodedData() else {
            return nil
        }
        
        let sealResult = sodium.box.seal(message: stringBytes, recipientPublicKey: publicKeyBytes)
        
        return sealResult?.base64EncodedString()
    }
    
    func createSignature(string: String, privateKey: String) -> String? {
        let stringBytes = string.bytes
        let sodium = Sodium()
        
        guard let privateKeyBytes = privateKey.base64EncodedData() else {
            return nil
        }
        
        let signature = sodium.sign.signature(message: stringBytes, secretKey: privateKeyBytes)
        
        return signature?.base64EncodedString()
    }
}

extension Bytes {
    func base64EncodedString() -> String {
        Data(self).base64EncodedString()
    }
}

extension String {
    func base64EncodedData() -> [UInt8]? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return [UInt8](data)
    }
}
