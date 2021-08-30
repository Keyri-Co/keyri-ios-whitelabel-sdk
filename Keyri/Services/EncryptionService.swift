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
        let keyPair = sodium.box.keyPair()!
//        let publicKeyString = Data(bytes: keyPair.publicKey, count: keyPair.publicKey.count).base64EncodedString()
//        let privateKeyString = Data(bytes: keyPair.secretKey, count: keyPair.secretKey.count).base64EncodedString()
//        let publicKeyString = sodium.utils.bin2base64(keyPair.publicKey)!
//        let privateKeyString = sodium.utils.bin2base64(keyPair.secretKey)!
        let publicKeyString = Data(keyPair.publicKey).base64EncodedString()
        let privateKeyString = Data(keyPair.secretKey).base64EncodedString()
        
        return CryptoBox(publicKey: publicKeyString, privateKey: privateKeyString)
    }
    
    func encryptSodium(string: String, publicKey: String, privateKey: String) -> (authenticatedCipherText: String, nonce: String)? {
//        guard let stringBytes = string.base64String()?.bytes else {
//            return nil
//        }
        let stringBytes = string.bytes//.sodiumBytes()
        let sodium = Sodium()
//        let publicKeyBytes = publicKey.sodiumBytes()
//        let privateKeyBytes = privateKey.sodiumBytes()
        
//        let publicKeyBytes = publicKey.sodiumBytes()
//        let privateKeyBytes = privateKey.sodiumBytes()
        
//        let publicKeyBytes = sodium.utils.base642bin(publicKey)!
//        let privateKeyBytes = sodium.utils.base642bin(privateKey)!
        
//        let newPK = "0JWazrdDbLA+MwbqHjF9Mmo+3w2oh6IPBrgEFNLUfUw="
//        let newSK = "EdnAMTx0CvQ/c1fovJbpcJ2KuJwJaFWmjZGGOnTL7oU="
        
//        guard
//            let sealResult: (authenticatedCipherText: Bytes, nonce: Box.Nonce) = sodium.box.seal(message: stringBytes, recipientPublicKey: publicKeyBytes, senderSecretKey: privateKeyBytes)
//        else {
//            return nil
//        }
        
        let publicKeyBytes = [UInt8](Data(base64Encoded: publicKey)!)
        let privateKeyBytes = [UInt8](Data(base64Encoded: privateKey)!)
        
        guard
            let sealResult: (authenticatedCipherText: Bytes, nonce: Box.Nonce) = sodium.box.seal(message: stringBytes, recipientPublicKey: publicKeyBytes, senderSecretKey: privateKeyBytes)
        else {
            return nil
        }
        
        return (authenticatedCipherText: Data(sealResult.authenticatedCipherText).base64EncodedString(), nonce: Data(sealResult.nonce).base64EncodedString())
    }
}

extension String {
    func sodiumBytes() -> [UInt8] {
//        let nsData = NSData(base64Encoded: self, options: .ignoreUnknownCharacters)!
//        let bytes = [UInt8](nsData as Data)
//        return bytes
//        Sodium().utils.base642bin(self)!
        
        let data = Data(base64Encoded: self)!
        return [UInt8](data)
    }
    
    func base64String() -> String? {
        data(using: .utf8)?.base64EncodedString()
    }
}

extension Bytes {
    func base64String() -> String {
        Data(bytes: self, count: count).base64EncodedString()
    }
}
