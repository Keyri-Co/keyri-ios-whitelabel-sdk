//
//  Keyri.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 25.08.2021.
//

import Foundation
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
            self?.userService?.signUp(username: username, sessionId: sessionId, service: service, custom: custom, completion: completion)
        }
    }

    public func login(account: PublicAccount, service: Service, custom: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            guard let sessionId = self?.sessionService?.sessionId else {
                completion(.failure(KeyriErrors.keyriSdkError))
                assertionFailure(KeyriErrors.keyriSdkError.localizedDescription)
                return
            }
            self?.userService?.login(sessionId: sessionId, service: service, account: account, custom: custom, completion: completion)
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
            let sessionId = URLComponents(string: result)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""
            
            self?.onReadSessionId(sessionId, completion: { sessionResult in
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
                    let encryptionService = EncryptionService(rpPublicKey: Self.rpPublicKey)
                    self.encryptionService = encryptionService
                    let keychainService = KeychainService()
                    self.keychainService = keychainService
                    let sessionService = SessionService(keychainService: keychainService, encryptionService: encryptionService)
                    self.sessionService = sessionService
                    let storageService = StorageService()
                    self.storageService = storageService
                    self.userService = UserService(apiService: apiService, sessionService: sessionService, storageService: storageService, keychainService: keychainService, encryptionService: encryptionService)
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
