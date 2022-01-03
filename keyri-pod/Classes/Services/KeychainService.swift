//
//  KeychainService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation

final class KeychainService {
    private lazy var keychain = Keychain(service: "com.novos.keyri.Keyri")
    
    func set(value: String, forKey key: String) throws {
        try keychain.save(key: key, value: value)
    }
    
    func get(valueForKey key: String) throws -> String? {
        try keychain.load(key: key)
    }
    
    func remove(valueForKey key: String) throws {
        try keychain.remove(key: key)
    }
}
