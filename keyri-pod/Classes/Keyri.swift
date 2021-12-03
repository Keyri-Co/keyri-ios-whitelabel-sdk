//
//  Keyri.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 25.08.2021.
//

import Foundation
import Sodium
import UIKit
import CryptoSwift

public final class Keyri: NSObject {
    private static var appkey: String?
    private static var rpPublicKey: String?
    private static var callbackUrl: URL?
    
    private var scanner: Scanner?
    
    private var apiService: ApiService?
    private var userService: UserService?
    private var sessionService: SessionService?
    private var storageService: StorageService?
    private var keychainService: KeychainService?
    private var encryptionService: EncryptionService?
    
    @objc
    public static func configure(appkey: String, rpPublicKey: String? = nil, callbackUrl: URL) {
        Self.appkey = appkey
        Self.rpPublicKey = rpPublicKey
        Self.callbackUrl = callbackUrl
    }

    public func onReadSessionId(_ sessionId: String, completion: @escaping (Result<Session, Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            switch result {
            case .success(_):
                self?.sessionService?.sessionId = sessionId
                self?.apiService?.getSession(sessionId: sessionId) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let session):
                            if let currentSessionId = self?.sessionService?.sessionId, currentSessionId != sessionId {
                                completion(.failure(KeyriErrors.wrongConfigError))
                                return
                            }
                            completion(.success(session))
                        case .failure(let error):
                            self?.sessionService?.sessionId = nil
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func signUp(username: String, service: Service, custom: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            guard let sessionId = self?.sessionService?.sessionId else {
                completion(.failure(KeyriErrors.keyriSdkError))
                assertionFailure(KeyriErrors.keyriSdkError.localizedDescription)
                return
            }
            self?.userService?.signUp(username: username, sessionId: sessionId, service: service, rpPublicKey: Self.rpPublicKey, custom: custom, completion: completion)
        }
    }

    public func login(account: PublicAccount, service: Service, custom: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            guard let sessionId = self?.sessionService?.sessionId else {
                completion(.failure(KeyriErrors.keyriSdkError))
                assertionFailure(KeyriErrors.keyriSdkError.localizedDescription)
                return
            }
            self?.userService?.login(sessionId: sessionId, service: service, account: account, rpPublicKey: Self.rpPublicKey, custom: custom, completion: completion)
        }
    }
    
    public func mobileSignUp(username: String, custom: String?, extendedHeaders: [String: String]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            switch result {
            case .success(let service):
                self?.apiService?.permissions(service: service, permissions: [.mobileSignUp]) { result in
                    guard let callbackUrl = Self.callbackUrl else {
                        completion(.failure(KeyriErrors.permissionsError))
                        assertionFailure(KeyriErrors.permissionsError.localizedDescription)
                        return
                    }
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let permissions):
                            if permissions[.mobileSignUp] == true {
                                self?.userService?.mobileSignUp(username: username, service: service, callbackUrl: callbackUrl, custom: custom, extendedHeaders: extendedHeaders, completion: completion)
                            } else {
                                completion(.failure(KeyriErrors.permissionsError))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func mobileLogin(account: PublicAccount, custom: String?, extendedHeaders: [String: String]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            switch result {
            case .success(let service):
                self?.apiService?.permissions(service: service, permissions: [.mobileLogin]) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let permissions):
                            if permissions[.mobileLogin] == true {
                                guard let callbackUrl = Self.callbackUrl else {
                                    completion(.failure(KeyriErrors.keyriSdkError))
                                    assertionFailure(KeyriErrors.keyriSdkError.localizedDescription)
                                    return
                                }
                                self?.userService?.mobileLogin(account: account, service: service, callbackUrl: callbackUrl, custom: custom, extendedHeaders: extendedHeaders, completion: completion)
                            } else {
                                completion(.failure(KeyriErrors.keyriSdkError))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func accounts(completion: @escaping (Result<[PublicAccount], Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            switch result {
            case .success(let service):
                
                let serverPublicKey = "BOenio0DXyG31mAgUCwhdslelckmxzM7nNOyWAjkuo7skr1FhP7m2L8PaSRgIEH5ja9p+CwEIIKGqR4Hx5Ezam4="
                let secret = try! self?.encryptionService?.keysExchange(publicKey: serverPublicKey)
                
//                let orig = "hello"
//                let encData = AES.encryptionAESModeECB(messageData: orig.data(using: .utf8), key: secret!)!
//                let encString = encData.utf8String()!
//
//                let decData = AES.decryptionAESModeECB(messageData: encString.data(using: .utf8), key: secret!)!
//                let decString = decData.utf8String()!
                
                let orig = "hello Denys"
                
                
                /* Generate random IV value. IV is public value. Either need to generate, or get it from elsewhere */
                let iv =  Array("1234567891234567".data(using: .utf8)!)

                /* AES cryptor instance */
                let aes = try! AES(key: Array(secret!.base64EncodedData()!) , blockMode: CBC(iv: iv), padding: .pkcs7)


                /* Encrypt Data */
                let inputData = orig.data(using: .utf8)!
                let encryptedBytes = try! aes.encrypt(inputData.bytes)
                let encryptedData = Data(encryptedBytes)
                let enc = try! encryptedData.base64EncodedString()
                
                /* Decrypt Data */
                let decryptedBytes = try! aes.decrypt(Array(enc.base64EncodedData()!))
                let decryptedData = Data(decryptedBytes)
                
                print(String(data: decryptedData, encoding: .utf8))
                
                
                
                let encString = AES_test.encryptionAESModeECBInUtf8(message: orig, key: secret!)
                
                let decString = AES_test.decryptionAESModeECBInUtf8(message: encString, key: secret!)
                
                let spkiKey = try! self?.encryptionService?.spkiPublicKey()
                
                print("")

                completion(.success(
                    self?.storageService?.getAllAccounts(serviceId: service.id).map { PublicAccount(username: $0.username, custom: $0.custom) } ?? []
                ))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func authWithScanner(from viewController: UIViewController? = nil, custom: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        scanner = Scanner()
        scanner?.completion = { [weak self] result in
            self?.onReadSessionId(result, completion: { sessionResult in
                switch sessionResult {
                case .success(let session):
                    if session.isNewUser {
                        guard let username = session.username else { return }
                        self?.signUp(username: username, service: session.service, custom: custom, completion: completion)
                    } else {
                        self?.accounts() { result in
                            if case .success(let accounts) = result, let account = accounts.first {
                                self?.login(account: account, service: session.service, custom: custom, completion: completion)
                            } else {
                                completion(.failure(KeyriErrors.accountNotFoundError))
                            }
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        scanner?.show()
    }
}

extension Keyri {
    private func whitelabelInitIfNeeded(completion: @escaping ((Result<Service, Error>) -> Void)) {
        guard let appkey = Self.appkey, let _ = Self.callbackUrl else {
            completion(.failure(KeyriErrors.notInitializedError))
            return
        }
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            assertionFailure(KeyriErrors.notInitializedError.errorDescription ?? "")
            completion(.failure(KeyriErrors.notInitializedError))
            return
        }
        
        if let service = apiService?.service {
            completion(.success(service))
            return
        }

        ApiService.whitelabelInit(appKey: appkey, deviceId: deviceId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let apiService):
                    self.apiService = apiService
                    let encryptionService = EncryptionService()
                    self.encryptionService = encryptionService
                    let keychainService = KeychainService(encryptionService: encryptionService)
                    self.keychainService = keychainService
                    let sessionService = SessionService(keychainService: keychainService, encryptionService: encryptionService)
                    self.sessionService = sessionService
                    let storageService = StorageService()
                    self.storageService = storageService
                    self.userService = UserService(apiService: apiService, sessionService: sessionService, storageService: storageService, keychainService: keychainService)
                    completion(.success(apiService.service))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

extension Keyri {
    
    @objc
    public func onReadSessionId(_ sessionId: String, completion: @escaping (Session?, Error?) -> Void) {
        onReadSessionId(sessionId) { (result: Result<Session, Error>) in
            switch result {
            case .success(let service):
                completion(service, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    @objc
    public func signUp(username: String, service: Service, custom: String?, completion: @escaping (Error?) -> Void) {
        signUp(username: username, service: service, custom: custom) { (result: Result<Void, Error>) in
            switch result {
            case .success():
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    @objc
    public func login(account: PublicAccount, service: Service, custom: String?, completion: @escaping (Error?) -> Void) {
        login(account: account, service: service, custom: custom) { (result: Result<Void, Error>) in
            switch result {
            case .success():
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    @objc
    public func mobileSignUp(username: String, custom: String?, extendedHeaders: [String: String]? = nil, completion: @escaping ([String: Any]?, Error?) -> Void) {
        mobileSignUp(username: username, custom: custom, extendedHeaders: extendedHeaders) { (result: Result<[String : Any], Error>) in
            switch result {
            case .success(let json):
                completion(json, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    @objc
    public func mobileLogin(account: PublicAccount, custom: String?, extendedHeaders: [String: String]? = nil, completion: @escaping ([String: Any]?, Error?) -> Void) {
        mobileLogin(account: account, custom: custom, extendedHeaders: extendedHeaders) { (result: Result<[String : Any], Error>) in
            switch result {
            case .success(let json):
                completion(json, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    @objc
    public func accounts(completion: @escaping ([PublicAccount]?, Error?) -> Void) {
        accounts { (result: Result<[PublicAccount], Error>) in
            switch result {
            case .success(let account):
                completion(account, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    @objc
    public func authWithScanner(from viewController: UIViewController? = nil, custom: String?, completion: @escaping (Error?) -> Void) {
        authWithScanner(from: viewController, custom: custom) { (result: Result<Void, Error>) in
            switch result {
            case .success():
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
