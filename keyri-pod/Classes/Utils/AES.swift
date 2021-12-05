//
//  AES.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation
import CommonCrypto
import CryptoSwift

final class CryptoAES {
//    private lazy var config = Config()
//    private lazy var ivAes = config.ivAes

    static func aesEncrypt(string: String, secret: String) -> String? {
        guard
            let ivData = Config().ivAes.data(using: .utf8),
            let secretBase64EncodedData = secret.base64EncodedData(),
            let stringData = string.data(using: .utf8),
            let aes = try? AES(key: Array(secretBase64EncodedData), blockMode: CBC(iv: Array(ivData)), padding: .pkcs7)
        else { return nil }
        
        return try? aes.encrypt(stringData.bytes).base64EncodedString()
    }
    
    static func aesDecrypt(string: String, secret: String) -> String? {
        guard
            let ivData = Config().ivAes.data(using: .utf8),
            let secretBase64EncodedData = secret.base64EncodedData(),
            let stringData = string.base64EncodedData(),
            let aes = try? AES(key: Array(secretBase64EncodedData), blockMode: CBC(iv: Array(ivData)), padding: .pkcs7),
            let decryptedBytes = try? aes.decrypt(stringData)
        else { return nil }
                
        return Data(decryptedBytes).utf8String()
    }
}

final class AES_test {
    static func encryptionAESModeECB(messageData data: Data?, key: String) -> Data? {
        guard let data = data else { return nil }
        guard let keyData = key.data(using: String.Encoding.utf8) else { return nil }
        guard let cryptData = NSMutableData(length: Int((data.count)) + kCCBlockSizeAES128) else { return nil }
        
        let keyLength               = size_t(kCCKeySizeAES128)
        let operation:  CCOperation = UInt32(kCCEncrypt)
        let algoritm:   CCAlgorithm = UInt32(kCCAlgorithmAES)
        let options:    CCOptions   = UInt32(kCCOptionECBMode + kCCOptionPKCS7Padding)
        let iv:         String      = ""
        
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = CCCrypt(operation,
                                  algoritm,
                                  options,
                                  (keyData as NSData).bytes, keyLength,
                                  iv,
                                  (data as NSData).bytes, data.count,
                                  cryptData.mutableBytes, cryptData.length,
                                  &numBytesEncrypted)
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.length = Int(numBytesEncrypted)
            let encryptedString = cryptData.base64EncodedString(options: .lineLength64Characters)
            return encryptedString.data(using: .utf8)
        } else {
            return nil
        }
    }

    static func decryptionAESModeECB(messageData: Data?, key: String) -> Data? {
        guard let messageData = messageData else { return nil }
        guard let messageString = String(data: messageData, encoding: .utf8) else { return nil }
        guard let data = Data(base64Encoded: messageString, options: .ignoreUnknownCharacters) else { return nil }
        guard let keyData = key.data(using: String.Encoding.utf8) else { return nil }
        guard let cryptData = NSMutableData(length: Int((data.count)) + kCCBlockSizeAES128) else { return nil }
        
        let keyLength               = size_t(kCCKeySizeAES128)
        let operation:  CCOperation = UInt32(kCCDecrypt)
        let algoritm:   CCAlgorithm = UInt32(kCCAlgorithmAES)
        let options:    CCOptions   = UInt32(kCCOptionECBMode + kCCOptionPKCS7Padding)
        let iv:         String      = ""
        
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = CCCrypt(operation,
                                  algoritm,
                                  options,
                                  (keyData as NSData).bytes, keyLength,
                                  iv,
                                  (data as NSData).bytes, data.count,
                                  cryptData.mutableBytes, cryptData.length,
                                  &numBytesEncrypted)
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.length = Int(numBytesEncrypted)
            return cryptData as Data
        } else {
            return nil
        }
    }
}

extension AES_test {
    static func encryptionAESModeECBInUtf8(message: String?, key: String) -> String? {
        Self.encryptionAESModeECB(messageData: message?.data(using: .utf8), key: key)?.utf8String()
    }
    
    static func decryptionAESModeECBInUtf8(message: String?, key: String) -> String? {
        Self.decryptionAESModeECB(messageData: message?.data(using: .utf8), key: key)?.utf8String()
    }
}
