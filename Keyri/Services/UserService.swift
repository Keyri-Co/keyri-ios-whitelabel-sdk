//
//  UserService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation
import UIKit

final class UserService {
    static let shared = UserService()
    private init() {}
    
    func signUp(username: String, sessionId: String, service: Service, custom: String?) {
        
        let encUserId = createUser(username: username, service: service, custom: custom).encUserId!
        
        SessionService.shared.verifyUserSession(encUserId: encUserId, sessionId: sessionId)
    }
    
    func login(sessionId: String, service: Service, account: PublicAccount, custom: String?) {
        guard let sessionAccount = StorageService.shared.getAllAccounts(serviceId: service.id).first(where: { $0.username == account.username })  else {
            print("no account found")
            return
        }
        
        SessionService.shared.verifyUserSession(encUserId: sessionAccount.userId, sessionId: sessionId)
    }
    
    func mobileLogin(account: PublicAccount, service: Service, callbackUrl: URL?, custom: String?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard
            let sessionAccount = StorageService.shared.getAllAccounts(serviceId: service.id).first(where: { $0.username == account.username }),
            let callbackUrl = callbackUrl
        else {
            print("no account found")
            return
        }
        
        let encUserId = sessionAccount.userId
        
        let box = KeychainService.shared.getCryptoBox()
        let userIdData = AES.decryptionAESModeECB(messageData: encUserId.data(using: .utf8)!, key: box.privateKey)!
        let userId = String(data: userIdData, encoding: .utf8)!
        
        ApiService.shared.authMobile(url: callbackUrl, userId: userId, username: sessionAccount.username, completion: completion)
    }
    
    func mobileSignUp(username: String, service: Service, callbackUrl: URL?, custom: String?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let account = createUser(username: username, service: service, custom: custom).account
        guard let encUserId = account?.userId, let callbackUrl = callbackUrl else {
            fatalError("")
        }
        
        let box = KeychainService.shared.getCryptoBox()
        let userIdData = AES.decryptionAESModeECB(messageData: encUserId.data(using: .utf8)!, key: box.privateKey)!
        let userId = String(data: userIdData, encoding: .utf8)!
        
        ApiService.shared.authMobile(url: callbackUrl, userId: userId, username: username, completion: completion)
    }
}

extension UserService {
    private func createUser(username: String, service: Service, custom: String?) -> (account: Account?, encUserId: String?) {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            fatalError(KeyriErrors.generic.errorDescription ?? "")
        }
        
        let uniqueId = String.random()
        
        let encryptTarget = "\(deviceId)\(uniqueId)"
        
        let box = KeychainService.shared.getCryptoBox()
        
        let userIdData = AES.encryptionAESModeECB(messageData: encryptTarget.data(using: .utf8)!, key: box.privateKey)!
        let encUserIdData = AES.encryptionAESModeECB(messageData: userIdData, key: box.privateKey)!
        let encUserId = String(data: encUserIdData, encoding: .utf8)!
                    
        let account = Account(userId: encUserId, username: username, custom: custom)
        StorageService.shared.set(service: service)
        StorageService.shared.add(account: account, serviceId: service.id)
        
        return (account, encUserId)
    }
}
