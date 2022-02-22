//
//  Keyri.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 25.08.2021.
//

import Foundation
import UIKit

/**
 * Keyri SDK public API.
 */
public final class Keyri: NSObject {
    private static var appkey: String?
    private static var rpPublicKey: String?
    private static var callbackUrl: URL?
    static var assertionEnabled: Bool = false
    
    private var scanner: Scanner?
    
    private var apiService: ApiService?
    private var userService: UserService?
    private var sessionService: SessionService?
    private var storageService: StorageService?
    private var keychainService: KeychainService?
    private var encryptionService: EncryptionService?
    
    /**
     *  SDK configuration
     * - Parameters:
     *  - appkey: Application unique key
     *  - rpPublicKey: server public key
     *  - callbackUrl: Sever callback URL
     */
    @objc
    public static func initialize(appkey: String, rpPublicKey: String? = nil, callbackUrl: URL) {
        Self.appkey = appkey
        Self.rpPublicKey = rpPublicKey
        Self.callbackUrl = callbackUrl
    }

    /**
     * Retrieves user session by given sessionId.
     * If session doesn't match Keyri configuration, returns wrongConfigError as failure result in completion
     * - Parameters:
     *  - sessionId: session id for user session
     *  - completion: returns Session object or wrongConfigError
     */
    public func handleSessionId(_ sessionId: String, completion: @escaping (Result<Session, Error>) -> Void) {
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

    /**
     * Create new user for Desktop agent
     *
     * If allowMultipleAccounts is false, returns multipleAccountsNotAllowedError as failure result in completion.
     * Must be called after onReadSessionId, if isNewUser is true
     *
     * - Parameters:
     *  - username: for new user
     *  - service: obtained Session from onReadSessionId
     *  - custom: custom argument
     *  - completion: returns Void if success or keyriSdkError if something went wrong
     */
    public func sessionSignup(username: String, service: Service, custom: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            guard let sessionId = self?.sessionService?.sessionId else {
                completion(.failure(KeyriErrors.keyriSdkError))
                Assertion.failure(KeyriErrors.keyriSdkError.localizedDescription)
                return
            }
            self?.userService?.signUp(username: username, sessionId: sessionId, service: service, custom: custom, completion: completion)
        }
    }

    /**
     * Login user for Desktop agent
     *
     * Must be called after onReadSessionId, if isNewUser is false
     *
     * - Parameters:
     *  - account: pass created earlier publicAccount
     *  - service: obtained Session from onReadSessionId
     *  - custom: custom argument
     *  - completion: returns Void if success or keyriSdkError if something went wrong
     */
    public func sessionLogin(account: PublicAccount, service: Service, custom: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            guard let sessionId = self?.sessionService?.sessionId else {
                completion(.failure(KeyriErrors.keyriSdkError))
                Assertion.failure(KeyriErrors.keyriSdkError.localizedDescription)
                return
            }
            self?.userService?.login(sessionId: sessionId, service: service, account: account, custom: custom, completion: completion)
        }
    }
    
    /**
     * Create new user on mobile device. If allowMultipleAccounts is false,
     * returns multipleAccountsNotAllowedError as failure result in completion
     *
     * - Parameters:
     *  - username: for new user
     *  - custom: custom argument
     *  - extendedHeaders: custom headers
     *  - completion: returns response dictionary if success or keyriSdkError if something went wrong
     */
    public func directSignup(username: String, custom: String? = nil, extendedHeaders: [String: String]? = nil, completion: @escaping (Result<AuthMobileResponse, Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            switch result {
            case .success(let service):
                self?.apiService?.permissions(service: service, permissions: [.mobileSignUp]) { result in
                    guard let callbackUrl = Self.callbackUrl else {
                        completion(.failure(KeyriErrors.permissionsError))
                        Assertion.failure(KeyriErrors.permissionsError.localizedDescription)
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

    /**
     * Login user on mobile device
     *
     * - Parameters:
     *  - account: pass created earlier publicAccount
     *  - custom: custom argument
     *  - extendedHeaders: custom headers
     *  - completion: returns response dictionary if success or keyriSdkError if something went wrong
     */
    public func directLogin(account: PublicAccount, custom: String? = nil, extendedHeaders: [String: String]? = nil, completion: @escaping (Result<AuthMobileResponse, Error>) -> Void) {
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
                                    Assertion.failure(KeyriErrors.keyriSdkError.localizedDescription)
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

    /**
     * Retrieves all public accounts on device.
     */
    public func getAccounts(completion: @escaping (Result<[PublicAccount], Error>) -> Void) {
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
     
    /**
     * Removing passed account
     */
    public func removeAccount(account: PublicAccount, completion: @escaping (Result<Void, Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            switch result {
            case .success(let service):
                self?.storageService?.remove(account: account, from: service)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /**
     * Create new user on mobile device or login if user already exist. If allowMultipleAccounts is false,
     * returns multipleAccountsNotAllowedError as failure result in completion
     *
     * - Parameters:
     *  - viewController: root view controller from which scanner will be presented or UIApplication keyWindow rootViewController in case if viewController argument is nil
     *  - custom: custom argument
     *  - completion: returns Void if success or accountNotFoundError if fails to login
     */
    public func easyKeyriAuth(from viewController: UIViewController? = nil, custom: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        scanner = Scanner()
        scanner?.completion = { [weak self] result in
            let sessionId = URLComponents(string: result)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""
            
            self?.handleSessionId(sessionId, completion: { sessionResult in
                switch sessionResult {
                case .success(let session):
                    if session.isNewUser {
                        guard let username = session.username else { return }
                        self?.sessionSignup(username: username, service: session.service, custom: custom, completion: completion)
                    } else {
                        self?.getAccounts() { result in
                            if case .success(let accounts) = result, let account = accounts.first {
                                self?.sessionLogin(account: account, service: session.service, custom: custom, completion: completion)
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
        scanner?.show(from: viewController)
    }
}

extension Keyri {
    private func whitelabelInitIfNeeded(completion: @escaping ((Result<Service, Error>) -> Void)) {
        guard let appkey = Self.appkey, let _ = Self.callbackUrl else {
            completion(.failure(KeyriErrors.notInitializedError))
            return
        }
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            Assertion.failure(KeyriErrors.notInitializedError.errorDescription ?? "")
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
                    let keychainService = KeychainService()
                    self.keychainService = keychainService
                    let encryptionService = EncryptionService(keychainService: keychainService, rpPublicKey: Self.rpPublicKey)
                    self.encryptionService = encryptionService
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
    
    /**
     * Retrieves user session by given sessionId.
     * If session doesn't match Keyri configuration, returns wrongConfigError as failure result in completion
     * - Parameters:
     *  - sessionId: session id for user session
     *  - completion: returns Session object or wrongConfigError
     */
    @objc
    public func handleSessionId(_ sessionId: String, completion: @escaping (Session?, Error?) -> Void) {
        handleSessionId(sessionId) { (result: Result<Session, Error>) in
            switch result {
            case .success(let service):
                completion(service, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    /**
     * Create new user for Desktop agent
     *
     * If allowMultipleAccounts is false, returns multipleAccountsNotAllowedError as failure result in completion.
     * Must be called after onReadSessionId, if isNewUser is true
     *
     * - Parameters:
     *  - username: for new user
     *  - service: obtained Session from onReadSessionId
     *  - custom: custom argument
     *  - completion: returns Void if success or keyriSdkError if something went wrong
     */
    @objc
    public func sessionSignup(username: String, service: Service, custom: String? = nil, completion: @escaping (Error?) -> Void) {
        sessionSignup(username: username, service: service, custom: custom) { (result: Result<Void, Error>) in
            switch result {
            case .success():
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    /**
     * Login user for Desktop agent
     *
     * Must be called after onReadSessionId, if isNewUser is false
     *
     * - Parameters:
     *  - account: pass created earlier publicAccount
     *  - service: obtained Session from onReadSessionId
     *  - custom: custom argument
     *  - completion: returns Void if success or keyriSdkError if something went wrong
     */
    @objc
    public func sessionLogin(account: PublicAccount, service: Service, custom: String? = nil, completion: @escaping (Error?) -> Void) {
        sessionLogin(account: account, service: service, custom: custom) { (result: Result<Void, Error>) in
            switch result {
            case .success():
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    /**
     * Create new user on mobile device. If allowMultipleAccounts is false,
     * returns multipleAccountsNotAllowedError as failure result in completion
     *
     * - Parameters:
     *  - username: for new user
     *  - custom: custom argument
     *  - extendedHeaders: custom headers
     *  - completion: returns response dictionary if success or keyriSdkError if something went wrong
     */
    @objc
    public func directSignup(username: String, custom: String? = nil, extendedHeaders: [String: String]? = nil, completion: @escaping (AuthMobileResponse?, Error?) -> Void) {
        directSignup(username: username, custom: custom, extendedHeaders: extendedHeaders) { (result: Result<AuthMobileResponse, Error>) in
            switch result {
            case .success(let json):
                completion(json, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    /**
     * Login user on mobile device
     *
     * - Parameters:
     *  - account: pass created earlier publicAccount
     *  - custom: custom argument
     *  - extendedHeaders: custom headers
     *  - completion: returns response dictionary if success or keyriSdkError if something went wrong
     */
    @objc
    public func directLogin(account: PublicAccount, custom: String? = nil, extendedHeaders: [String: String]? = nil, completion: @escaping (AuthMobileResponse?, Error?) -> Void) {
        directLogin(account: account, custom: custom, extendedHeaders: extendedHeaders) { (result: Result<AuthMobileResponse, Error>) in
            switch result {
            case .success(let json):
                completion(json, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    /**
     * Retrieves all public accounts on device.
     */
    @objc
    public func getAccounts(completion: @escaping ([PublicAccount]?, Error?) -> Void) {
        getAccounts { (result: Result<[PublicAccount], Error>) in
            switch result {
            case .success(let account):
                completion(account, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    /**
     * Removing passed account
     */
    @objc
    public func removeAccount(account: PublicAccount, completion: @escaping (Error?) -> Void) {
        removeAccount(account: account) { (result: Result<Void, Error>) in
            switch result {
            case .success():
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    /**
     * Create new user on mobile device or login if user already exist. If allowMultipleAccounts is false,
     * returns multipleAccountsNotAllowedError as failure result in completion
     *
     * - Parameters:
     *  - viewController: root view controller from which scanner will be presented
     *  - custom: custom argument
     *  - completion: returns Void if success or accountNotFoundError if fails to login
     */
    @objc
    public func easyKeyriAuth(from viewController: UIViewController? = nil, custom: String? = nil, completion: @escaping (Error?) -> Void) {
        easyKeyriAuth(from: viewController, custom: custom) { (result: Result<Void, Error>) in
            switch result {
            case .success():
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
