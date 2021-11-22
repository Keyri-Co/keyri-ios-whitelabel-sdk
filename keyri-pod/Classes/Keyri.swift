//
//  Keyri.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 25.08.2021.
//

import Foundation
import Sodium
import UIKit

public final class Keyri: NSObject {
    private var appkey: String?
    private var rpPublicKey: String?
    private var callbackUrl: URL?
    
    private var scanner: Scanner?
    
    private var apiService: ApiService?
    private var userService: UserService?
    private var sessionService: SessionService?
    private var storageService: StorageService?
    private var keychainService: KeychainService?
    private var encryptionService: EncryptionService?
    
    @objc
    public static let shared = Keyri()

    private override init() {}

    @objc
    @discardableResult
    public func initialize(appkey: String, rpPublicKey: String? = nil, callbackUrl: URL) -> Error? {
        self.appkey = appkey
        self.rpPublicKey = rpPublicKey
        self.callbackUrl = callbackUrl

        do {
            let _ = try keychainService?.getCryptoBox()
            print("KeyriSDK initialized successfully")
        } catch {
            print("KeyriSDK initialization failed with error - \(error.localizedDescription)")
            return error
        }
        return nil
    }

    public func onReadSessionId(_ sessionId: String, completion: @escaping (Result<Session, Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            switch result {
            case .success(_):
//                ApiService.shared.permissions(service: service, permissions: [.getSession]) { result in
//                    switch result {
//                    case .success(let permissions):
//                        if permissions[.getSession] == true {
                            self?.apiService?.getSession(sessionId: sessionId) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success(let session):
                                        self?.sessionService?.sessionId = sessionId
                                        completion(.success(session))
                                    case .failure(let error):
                                        self?.sessionService?.sessionId = nil
                                        completion(.failure(error))
                                    }
                                }
                            }
//                        } else {
//                            completion(.failure(KeyriErrors.serviceAccessDenied))
//                        }
//                    case .failure(let error):
//                        completion(.failure(error))
//                    }
//                }
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
//            ApiService.shared.permissions(service: service, permissions: [.signUp]) { result in
//                switch result {
//                case .success(let permissions):
//                    if permissions[.signUp] == true {
                        self?.userService?.signUp(username: username, sessionId: sessionId, service: service, rpPublicKey: self?.rpPublicKey, custom: custom, completion: completion)
//                    } else {
//                        completion(.failure(KeyriErrors.serviceAccessDenied))
//                    }
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
        }
    }

    public func login(account: PublicAccount, service: Service, custom: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            guard let sessionId = self?.sessionService?.sessionId else {
                completion(.failure(KeyriErrors.keyriSdkError))
                assertionFailure(KeyriErrors.keyriSdkError.localizedDescription)
                return
            }
//            ApiService.shared.permissions(service: service, permissions: [.login]) { result in
//                switch result {
//                case .success(let permissions):
//                    if permissions[.login] == true {
                        self?.userService?.login(sessionId: sessionId, service: service, account: account, rpPublicKey: self?.rpPublicKey, custom: custom, completion: completion)
//                    } else {
//                        completion(.failure(KeyriErrors.serviceAccessDenied))
//                    }
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
        }
    }
    
    public func mobileSignUp(username: String, custom: String?, extendedHeaders: [String: String]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            switch result {
            case .success(let service):
                self?.apiService?.permissions(service: service, permissions: [.mobileSignUp]) { result in
                    guard let callbackUrl = self?.callbackUrl else {
                        completion(.failure(KeyriErrors.keyriSdkError))
                        assertionFailure(KeyriErrors.keyriSdkError.localizedDescription)
                        return
                    }
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let permissions):
                            if permissions[.mobileSignUp] == true {
                                self?.userService?.mobileSignUp(username: username, service: service, callbackUrl: callbackUrl, custom: custom, extendedHeaders: extendedHeaders, completion: completion)
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

    public func mobileLogin(account: PublicAccount, custom: String?, extendedHeaders: [String: String]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            switch result {
            case .success(let service):
                self?.apiService?.permissions(service: service, permissions: [.mobileLogin]) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let permissions):
                            if permissions[.mobileLogin] == true {
                                guard let callbackUrl = self?.callbackUrl else {
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
//                ApiService.shared.permissions(service: service, permissions: [.accounts]) { result in
//                    switch result {
//                    case .success(let permissions):
//                        if permissions[.accounts] == true {
                            completion(.success(
                                self?.storageService?.getAllAccounts(serviceId: service.id).map { PublicAccount(username: $0.username, custom: $0.custom) } ?? []
                            ))
//                        } else {
//                            completion(.failure(KeyriErrors.serviceAccessDenied))
//                        }
//                    case .failure(let error):
//                        completion(.failure(error))
//                    }
//                }
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
                                Keyri.shared.login(account: account, service: session.service, custom: custom, completion: completion)
                            } else {
                                completion(.failure(KeyriErrors.accountNotFound))
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
        guard let appkey = appkey, let _ = callbackUrl else {
            completion(.failure(KeyriErrors.notInitialized))
            return
        }
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            assertionFailure(KeyriErrors.notInitialized.errorDescription ?? "")
            completion(.failure(KeyriErrors.notInitialized))
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
