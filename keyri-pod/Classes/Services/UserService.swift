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
    
    func signUp(username: String, sessionId: String, service: Service, rpPublicKey: String?, custom: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let encUserId = createUser(username: username, service: service, custom: custom).encUserId else {
            assertionFailure(KeyriErrors.keyriSdkError.errorDescription ?? "")
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }
        sessionService.verifyUserSession(encUserId: encUserId, sessionId: sessionId, rpPublicKey: rpPublicKey, custom: custom, usePublicKey: true, completion: completion)
    }
    
    func login(sessionId: String, service: Service, account: PublicAccount, rpPublicKey: String?, custom: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let sessionAccount = storageService.getAllAccounts(serviceId: service.id).first(where: { $0.username == account.username })  else {
            print("no account found")
            completion(.failure(KeyriErrors.accountNotFoundError))
            return
        }
        
        sessionService.verifyUserSession(encUserId: sessionAccount.userId, sessionId: sessionId, rpPublicKey: rpPublicKey, custom: custom, completion: completion)
    }
    
    func mobileLogin(account: PublicAccount, service: Service, callbackUrl: URL, custom: String?, extendedHeaders: [String: String]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard
            let sessionAccount = storageService.getAllAccounts(serviceId: service.id).first(where: { $0.username == account.username })
        else {
            print("no account found")
            completion(.failure(KeyriErrors.accountNotFoundError))
            return
        }
        
        let encUserId = sessionAccount.userId
        
        guard let box = try? keychainService.getCryptoBox() else {
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }
        guard
            let userIdData = AES_test.decryptionAESModeECB(messageData: encUserId.data(using: .utf8), key: box.privateKey),
            let userId = String(data: userIdData, encoding: .utf8)
        else {
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }
        
        apiService.authMobile(url: callbackUrl, userId: userId, username: sessionAccount.username, clientPublicKey: box.publicKey, extendedHeaders: extendedHeaders, completion: completion)
    }
    
    func mobileSignUp(username: String, service: Service, callbackUrl: URL, custom: String?, extendedHeaders: [String: String]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let account = createUser(username: username, service: service, custom: custom).account else {
            assertionFailure(KeyriErrors.keyriSdkError.errorDescription ?? "")
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }
        guard let box = try? keychainService.getCryptoBox() else {
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }
        guard
            let userIdData = AES_test.decryptionAESModeECB(messageData: account.userId.data(using: .utf8), key: box.privateKey),
            let userId = String(data: userIdData, encoding: .utf8) else {
            completion(.failure(KeyriErrors.keyriSdkError))
            return
        }
        
        apiService.authMobile(url: callbackUrl, userId: userId, username: username, clientPublicKey: box.publicKey, extendedHeaders: extendedHeaders, completion: completion)
    }
}

extension UserService {
    private func createUser(username: String, service: Service, custom: String?) -> (account: Account?, encUserId: String?) {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            assertionFailure(KeyriErrors.keyriSdkError.errorDescription ?? "")
            return (nil, nil)
        }
        
        let uniqueId = String.random()
        let encryptTarget = "\(deviceId)\(uniqueId)"
        
//        guard let box = try? keychainService.getCryptoBox() else {
//            assertionFailure(KeyriErrors.keyriSdkError.errorDescription ?? "")
//            return (nil, nil)
//        }
        guard
            let secret = encryptionService.getSecretKey(),
            let userId = CryptoAES.aesEncrypt(string: encryptTarget, secret: secret),
            let encUserId = CryptoAES.aesEncrypt(string: userId, secret: secret)
//            let userIdData = AES_test.encryptionAESModeECB(messageData: encryptTarget.data(using: .utf8), key: box.privateKey),
//            let encUserIdData = AES_test.encryptionAESModeECB(messageData: userIdData, key: box.privateKey),
//            let encUserId = String(data: encUserIdData, encoding: .utf8)
        else {
            assertionFailure(KeyriErrors.keyriSdkError.errorDescription ?? "")
            return (nil, nil)
        }
                    
        let account = Account(userId: encUserId, username: username, custom: custom)
        storageService.set(service: service)
        storageService.add(account: account, serviceId: service.id)
        
        return (account, encUserId)
    }
}
