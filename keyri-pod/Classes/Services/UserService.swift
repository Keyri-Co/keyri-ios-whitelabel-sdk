//
//  UserService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation
import UIKit

final class UserService {
    let apiService: ApiService
    let sessionService: SessionService
    let storageService: StorageService
    let keychainService: KeychainService
    let encryptionService: EncryptionService
    
    init(apiService: ApiService, sessionService: SessionService, storageService: StorageService, keychainService: KeychainService, encryptionService: EncryptionService) {
        self.apiService = apiService
        self.sessionService = sessionService
        self.storageService = storageService
        self.keychainService = keychainService
        self.encryptionService = encryptionService
    }
    
    func signUp(username: String, sessionId: String, service: Service, custom: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let encUserId = createUser(username: username, service: service, custom: custom).encUserId else {
            Assertion.failure(KeyriErrors.keyriSdkError.errorDescription ?? "")
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }
        sessionService.verifyUserSession(encUserId: encUserId, sessionId: sessionId, custom: custom, usePublicKey: true, completion: completion)
    }
    
    func login(sessionId: String, service: Service, account: PublicAccount, custom: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let sessionAccount = storageService.getAllAccounts(serviceId: service.id).first(where: { $0.username == account.username })  else {
            print("no account found")
            completion(.failure(KeyriErrors.accountNotFoundError))
            return
        }
        
        sessionService.verifyUserSession(encUserId: sessionAccount.userId, sessionId: sessionId, custom: custom, completion: completion)
    }
    
    func mobileLogin(account: PublicAccount, service: Service, callbackUrl: URL, custom: String?, extendedHeaders: [String: String]? = nil, completion: @escaping (Result<AuthMobileResponse, Error>) -> Void) {
        guard
            let sessionAccount = storageService.getAllAccounts(serviceId: service.id).first(where: { $0.username == account.username })
        else {
            print("no account found")
            completion(.failure(KeyriErrors.accountNotFoundError))
            return
        }
        
        let encUserId = sessionAccount.userId
        
        guard
            let userId = encryptionService.aesDecrypt(string: encUserId)
        else {
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }
        
        apiService.authMobile(url: callbackUrl, userId: userId, username: sessionAccount.username, clientPublicKey: try? encryptionService.loadPublicKeyString(), extendedHeaders: extendedHeaders, completion: completion)
    }
    
    func mobileSignUp(username: String, service: Service, callbackUrl: URL, custom: String?, extendedHeaders: [String: String]? = nil, completion: @escaping (Result<AuthMobileResponse, Error>) -> Void) {
        guard let account = createUser(username: username, service: service, custom: custom).account else {
            Assertion.failure(KeyriErrors.keyriSdkError.errorDescription ?? "")
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }
        guard
            let userId = encryptionService.aesDecrypt(string: account.userId)
        else {
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }
        
        apiService.authMobile(url: callbackUrl, userId: userId, username: username, clientPublicKey: try? encryptionService.loadPublicKeyString(), extendedHeaders: extendedHeaders, completion: completion)
    }
    
    func whitelabelAuth(custom: String, completion: @escaping (Result<Void, Error>) -> Void) {
        sessionService.whitelabelAuth(custom: custom, completion: completion)
    }
}

extension UserService {
    private func createUser(username: String, service: Service, custom: String?) -> (account: Account?, encUserId: String?) {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            Assertion.failure(KeyriErrors.keyriSdkError.errorDescription ?? "")
            return (nil, nil)
        }
        
        let uniqueId = String.random()
        let encryptTarget = "\(deviceId)\(uniqueId)"
        
        guard
            let userId = encryptionService.aesEncrypt(string: encryptTarget),
            let encUserId = encryptionService.aesEncrypt(string: userId)
        else {
            Assertion.failure(KeyriErrors.keyriSdkError.errorDescription ?? "")
            return (nil, nil)
        }
                    
        let account = Account(userId: encUserId, username: username, custom: custom)
        storageService.set(service: service)
        storageService.add(account: account, serviceId: service.id)
        
        return (account, encUserId)
    }
}
