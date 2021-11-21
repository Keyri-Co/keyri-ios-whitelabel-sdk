//
//  KeychainService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation

final class KeychainService {
    static let shared = KeychainService()
    private init() {}

    private lazy var keychain = Keychain(service: "com.novos.keyri.Keyri")
    
    func setCryptoBox(_ box: CryptoBox) {
        keychain["publicKey"] = box.publicKey
        keychain["privateKey"] = box.privateKey
    }
    
    func getCryptoBox() -> CryptoBox? {
        guard let publicKey = getPublicKey(), let privateKey = getPrivateKey() else {
            guard let box = EncryptionService.shared.generateCryproBox() else {
                return nil
            }
            setCryptoBox(box)
            return box
        }
        return CryptoBox(publicKey: publicKey, privateKey: privateKey)
    }
    
    func set(value: String, forKey key: String) {
        keychain[key] = value
    }
    
    func get(valueForKey key: String) -> String? {
        keychain[key]
    }
}

extension KeychainService {
    private func getPublicKey() -> String? {
        keychain["publicKey"]
    }

    private func getPrivateKey() -> String? {
        keychain["privateKey"]
    }
}
