//
//  EncryptionService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation
import Sodium
//import CryptoSwift

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
//    private lazy var config = Config()
//    private lazy var ivAes = config.ivAes
    
    func generateCryproBox() -> CryptoBox? {
        let sodium = Sodium()
        guard let keyPair = sodium.sign.keyPair() else {
            return nil
        }
        let publicKeyString = keyPair.publicKey.base64EncodedString()
        let privateKeyString = keyPair.secretKey.base64EncodedString()
        
        return CryptoBox(publicKey: publicKeyString, privateKey: privateKeyString)
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

extension EncryptionService {
    func loadKey(name: String = "com.novos.keyri.Keyri") throws -> SecKey {
        if let key = KeychainHelper.loadKey(name: name) {
            return key
        } else {
            return (try KeychainHelper.makeAndStoreKey(name: name))
        }
    }
    
    func loadPublicKey(name: String = "com.novos.keyri.Keyri") throws -> SecKey? {
        if let key = KeychainHelper.loadKey(name: name) {
            return SecKeyCopyPublicKey(key)
        } else {
            let key = (try KeychainHelper.makeAndStoreKey(name: name))
            return SecKeyCopyPublicKey(key)
        }
    }
    
    func ecdhEncrypt(string: String, publicKey: String) -> String? {
        guard
            let publicSecKey = KeychainHelper.convertbase64StringToSecKey(stringKey: publicKey)
        else { return nil }
        
        guard let data = string.data(using: .utf8) else { return nil }
        let encryptedData = SecKeyCreateEncryptedData(publicSecKey, .eciesEncryptionCofactorX963SHA256AESGCM, data as CFData, nil) as Data?
        return encryptedData?.base64EncodedString()
    }
    
    func ecdhDecrypt(string: String) -> String? {
        guard let privateSecKey = try? loadKey() else { return nil }
        guard let data = Data(base64Encoded: string) else { return nil }
        let decryptedData = SecKeyCreateDecryptedData(privateSecKey, .eciesEncryptionCofactorX963SHA256AESGCM, data as CFData, nil) as Data?
        return decryptedData?.utf8String()
    }
    
    func ecdhCreateSignature(string: String) -> String? {
        guard let privateKey = try? loadKey() else { return nil }
        guard let data = string.data(using: .utf8) else { return nil }
        let signature = SecKeyCreateSignature(privateKey, .ecdsaSignatureMessageX962SHA256, data as CFData, nil) as Data?
        return signature?.base64EncodedString()
    }
    
    func ecdhValidateSignature(string: String, signatureString: String) -> Bool {
        guard
            let privateKey = try? loadKey(),
            let publicKey = SecKeyCopyPublicKey(privateKey)
        else { return false }
        let algorithm: SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256
        guard
            SecKeyIsAlgorithmSupported(publicKey, .verify, algorithm),
            let clearTextData = string.data(using: .utf8),
            let signatureData = Data(base64Encoded: signatureString)
        else {
            return false
        }
        guard SecKeyVerifySignature(publicKey, algorithm, clearTextData as CFData, signatureData as CFData, nil) else {
            return false
        }
        
        return true
    }
    
    func keysExchange(publicKey: String) throws -> String? {
        let privateSecKey = try loadKey()
        guard let publicSecKey = KeychainHelper.convertbase64StringToSecKey(stringKey: publicKey) else {
            return nil
        }

        var error: Unmanaged<CFError>?
        guard let shared = SecKeyCopyKeyExchangeResult(privateSecKey, SecKeyAlgorithm.ecdhKeyExchangeCofactor, publicSecKey, [:] as CFDictionary, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        return shared.base64EncodedString()
    }
    
    // should be private
    func getSecretKey() -> String? {
        let serverPublicKey = "BOenio0DXyG31mAgUCwhdslelckmxzM7nNOyWAjkuo7skr1FhP7m2L8PaSRgIEH5ja9p+CwEIIKGqR4Hx5Ezam4="
        let secret = try! keysExchange(publicKey: serverPublicKey)
        return secret
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

final class KeychainHelper {
    static func makeAndStoreKey(name: String) throws -> SecKey {
        removeKey(name: name)

        let flags: SecAccessControlCreateFlags = .privateKeyUsage
        guard
            let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, flags, nil),
            let tag = name.data(using: .utf8)
        else {
            throw KeyriErrors.keyriSdkError
        }
        let attributes: [String: Any] = [
            kSecAttrKeyType as String       : kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String : 256,
            kSecAttrTokenID as String       : kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String       : true,
                kSecAttrApplicationTag as String    : tag,
                kSecAttrAccessControl as String     : access
            ]
        ]
                
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw (error?.takeRetainedValue() ?? KeyriErrors.keyriSdkError) as Error
        }
        
        return privateKey
    }
    
    static func loadKey(name: String) -> SecKey? {
        guard let tag = name.data(using: .utf8) else { return nil }
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag,
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecReturnRef as String             : true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let key = item else {
            return nil
        }
        return (key as! SecKey)
    }
    
    static func removeKey(name: String) {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag
        ]

        SecItemDelete(query as CFDictionary)
    }
    
    static func convertSecKeyToBase64String(secKey: SecKey) -> String? {
        var error: Unmanaged<CFError>?
        
        guard let keyData = SecKeyCopyExternalRepresentation(secKey, &error) as Data? else {
            fatalError()
        }
        let keyString = keyData.base64EncodedString()
        return keyString
    }
    
    static func convertbase64StringToSecKey(stringKey: String) -> SecKey? {
        guard let keyData = Data(base64Encoded: stringKey) else { return nil }
                
        let keyDict:[String: Any] = [
           kSecAttrKeyType as String: kSecAttrKeyTypeEC,
           kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
        ]
        
        return SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, nil)
    }
}
