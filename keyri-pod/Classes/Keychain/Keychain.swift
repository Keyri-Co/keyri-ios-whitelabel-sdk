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

    func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ] as [String : Any]

        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }

    func load(key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
    
    func remove(key: String) {
        let query = [
            kSecClass       : kSecClassGenericPassword,
            kSecAttrService : service,
            kSecAttrAccount : key ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
    }
}

extension Keychain {
    subscript(key: String) -> String? {
        get {
            load(key: key)?.utf8String()
        }
        set {
            if let data = newValue?.data(using: .utf8) {
                _ = save(key: key, data: data)
            } else {
                remove(key: key)
            }
        }
    }
}

extension Data {
    func utf8String() -> String? {
        String(data: self, encoding: .utf8)
    }
}
