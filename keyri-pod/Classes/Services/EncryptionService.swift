//
//  EncryptionService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation
import CryptoSwift

final class EncryptionService {
    private var rpPublicKey: String?
    
    init(rpPublicKey: String?) {
        self.rpPublicKey = rpPublicKey
    }
    
    func aesEncrypt(string: String) -> String? {
        guard
            let ivData = Data(base64Encoded: Config().ivAes),
            let secret = getSecretKey(),
            let secretBase64EncodedData = secret.base64EncodedData(),
            let stringData = string.data(using: .utf8),
            let aes = try? AES(key: Array(secretBase64EncodedData), blockMode: CBC(iv: Array(ivData)), padding: .pkcs7)
        else { return nil }
        
        return try? Data(aes.encrypt(stringData.bytes)).base64EncodedString()
    }
    
    func aesDecrypt(string: String) -> String? {
        guard
            let ivData = Data(base64Encoded: Config().ivAes),
            let secret = getSecretKey(),
            let secretBase64EncodedData = secret.base64EncodedData(),
            let stringData = string.base64EncodedData(),
            let aes = try? AES(key: Array(secretBase64EncodedData), blockMode: CBC(iv: Array(ivData)), padding: .pkcs7),
            let decryptedBytes = try? aes.decrypt(stringData)
        else { return nil }
                        
        return Data(decryptedBytes).utf8String()
    }
}

extension EncryptionService {
    private func loadKey(name: String = "com.novos.keyri.Keyri") throws -> SecKey {
        if let key = KeychainHelper.loadKey(name: name) {
            return key
        } else {
            return (try KeychainHelper.makeAndStoreKey(name: name))
        }
    }
    
    private func loadPublicKey(name: String = "com.novos.keyri.Keyri") throws -> SecKey? {
        if let key = KeychainHelper.loadKey(name: name) {
            return SecKeyCopyPublicKey(key)
        } else {
            let key = (try KeychainHelper.makeAndStoreKey(name: name))
            return SecKeyCopyPublicKey(key)
        }
    }
    
    func loadPublicKeyString(name: String = "com.novos.keyri.Keyri") throws -> String? {
        if let publicSecKey = try loadPublicKey(), let publicKey = KeychainHelper.convertSecKeyToBase64String(secKey: publicSecKey) {
            return publicKey
        } else {
            return nil
        }
    }
    
    private func keysExchange(publicKey: String) throws -> String? {
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
    
    private func getSecretKey() -> String? {
        guard let serverPublicKey = rpPublicKey else { return nil }
        let secret = try! keysExchange(publicKey: serverPublicKey)
        return secret
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
        let secp256r1Header = Data([
            0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01,
            0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00
        ])
        let completeData = secp256r1Header + keyData
        let keyString = completeData.base64EncodedString(options: .lineLength64Characters)
        return keyString.replacingOccurrences(of: "\r\n", with: "")
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
