//
//  Keychain.swift
//  keyri-pod
//
//  Created by Andrii Novoselskyi on 21.11.2021.
//

import Foundation

open class Keychain {
    let service: String
    
    public init(service: String) {
        self.service = service
    }

    public func save(key: String, data: Data) throws {
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
    
    public func save(key: String, value: String) throws {
        if let data = value.data(using: .utf8) {
            try save(key: key, data: data)
        }
    }


    public func load(key: String) -> Data? {
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
                return nil
            }
        } else {
            return nil
        }
    }
    
    func loadStr(key: String) throws -> String? {
        return load(key: key)?.utf8String()
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
    
    public func listKeys() -> [String:String]? {
        guard let query = [
                kSecClass as String : kSecClassGenericPassword,
                kSecAttrService : service
        ] as? [String: Any] else { return nil }
                        
        var result: AnyObject?
                    
        let lastResultCode = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
                    
        var values = [String:String]()
        if lastResultCode == noErr {
            if let array = result as? Array<Dictionary<String, Any>> {
                for item in array {
                    if let key = item[kSecAttrAccount as String] as? String,
                       let value = item[kSecValueData as String] as? Data {
                           values[key] = String(data: value, encoding:.utf8)
                     }
                 }
            }
                        
        }
                    
        return values
    }
}

extension Data {
    func utf8String() -> String? {
        String(data: self, encoding: .utf8)
    }
}
