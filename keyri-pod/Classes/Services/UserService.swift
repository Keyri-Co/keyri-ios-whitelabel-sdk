//
//  UserService.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 6/1/22.
//

import Foundation
import CryptoKit
import Security
import LocalAuthentication

open class UserService {
    let keychainService: Keychain
    
    public init() {
        keychainService = Keychain(service: "com.keyri")
    }
    
    public func verifyExistingUser(username: String) throws -> P256.Signing.PublicKey? {
        guard let data = keychainService.load(key: username) else { return nil }
        
        do {
            let derivedPrivateKey = try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: data)
            return derivedPrivateKey.publicKey
        } catch {
            throw KeyriErrors.iOSInternalError
        }
    }
    
    public func saveKey(for username: String) throws -> P256.Signing.PublicKey {
        do {
            let authContext = LAContext()
            let privateKey = try SecureEnclave.P256.Signing.PrivateKey(
              authenticationContext: authContext)
            
            let data = privateKey.dataRepresentation
            try keychainService.save(key: username, data: data)
            
            return privateKey.publicKey
        } catch {
            throw error
        }
    }
    
    public func sign(username: String, dataForSignature: Data) throws -> P256.Signing.ECDSASignature {
        guard let data = keychainService.load(key: username) else { throw KeyriErrors.accountNotFoundError }
        

        let derivedPrivateKey = try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: data)
        return try derivedPrivateKey.signature(for: dataForSignature)
        
    }
}

