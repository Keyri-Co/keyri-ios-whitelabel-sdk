//
//  KeychainService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation

final class KeychainService {
    let encryptionService: EncryptionService

    private lazy var keychain = Keychain(service: "com.novos.keyri.Keyri")
    
    init(encryptionService: EncryptionService) {
        self.encryptionService = encryptionService
    }
    
    private func setCryptoBox(_ box: CryptoBox) throws {
        try keychain.save(key: "publicKey", value: box.publicKey)
        try keychain.save(key: "privateKey", value: box.privateKey)
    }
    
    func getCryptoBox() throws -> CryptoBox? {
        guard let publicKey = try getPublicKey(), let privateKey = try getPrivateKey() else {
            guard let box = encryptionService.generateCryproBox() else {
                return nil
            }
            try setCryptoBox(box)
            return box
        }
        return CryptoBox(publicKey: publicKey, privateKey: privateKey)
    }
    
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

extension KeychainService {
    private func getPublicKey() throws -> String? {
        try keychain.load(key: "publicKey")
    }

    private func getPrivateKey() throws -> String? {
        try keychain.load(key: "privateKey")
    }
}
