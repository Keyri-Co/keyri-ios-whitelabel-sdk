//
//  Keychain.swift
//  keyri-pod
//
//  Created by Andrii Novoselskyi on 21.11.2021.
//

import Foundation

final class Keychain {
    let service: String
    
    init(service: String) {
        self.service = service
    }

    func save(key: String, data: Data) throws {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ] as [String : Any]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != noErr {
            throw KeyriErrors.keyriSdkError
        }
    }
    
    func save(key: String, value: String) throws {
        if let data = value.data(using: .utf8) {
            try save(key: key, data: data)
        }
    }

    func load(key: String) throws -> Data {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            if let data = dataTypeRef as? Data {
                return data
            } else {
                throw KeyriErrors.keyriSdkError
            }
        } else {
            throw KeyriErrors.keyriSdkError
        }
    }
    
    func load(key: String) throws -> String? {
        return try load(key: key).utf8String()
    }
    
    func remove(key: String) throws {
        let query = [
            kSecClass       : kSecClassGenericPassword,
            kSecAttrService : service,
            kSecAttrAccount : key ] as [String : Any]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != noErr {
            throw KeyriErrors.keyriSdkError
        }
    }
}

extension Data {
    func utf8String() -> String? {
        String(data: self, encoding: .utf8)
    }
}
