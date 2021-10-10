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
    private var appkey: String!
    private var rpPublicKey: String?
    private var callbackUrl: URL!
    
    private var scanner: Scanner?

    @objc
    public static let shared = Keyri()

    private override init() {}

    @objc
    public func initialize(appkey: String, rpPublicKey: String? = nil, callbackUrl: URL) {
        self.appkey = appkey
        self.rpPublicKey = rpPublicKey
        self.callbackUrl = callbackUrl

        let _ = KeychainService.shared.getCryptoBox()
    }

    public func onReadSessionId(_ sessionId: String, completion: @escaping (Result<Session, Error>) -> Void) {
        whitelabelInitIfNeeded { result in
            switch result {
            case .success(let service):
//                ApiService.shared.permissions(service: service, permissions: [.getSession]) { result in
//                    switch result {
//                    case .success(let permissions):
//                        if permissions[.getSession] == true {
                            ApiService.shared.getSession(sessionId: sessionId) { result in
                                switch result {
                                case .success(let session):
                                    SessionService.shared.sessionId = sessionId
                                    completion(.success(session))
                                case .failure(let error):
                                    SessionService.shared.sessionId = nil
                                    completion(.failure(error))
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
            guard let sessionId = SessionService.shared.sessionId else {
                completion(.failure(KeyriErrors.sessionNotFound))
                assertionFailure(KeyriErrors.sessionNotFound.localizedDescription)
                return
            }
//            ApiService.shared.permissions(service: service, permissions: [.signUp]) { result in
//                switch result {
//                case .success(let permissions):
//                    if permissions[.signUp] == true {
                        UserService.shared.signUp(username: username, sessionId: sessionId, service: service, rpPublicKey: self?.rpPublicKey, custom: custom, completion: completion)
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
            guard let sessionId = SessionService.shared.sessionId else {
                completion(.failure(KeyriErrors.sessionNotFound))
                assertionFailure(KeyriErrors.sessionNotFound.localizedDescription)
                return
            }
//            ApiService.shared.permissions(service: service, permissions: [.login]) { result in
//                switch result {
//                case .success(let permissions):
//                    if permissions[.login] == true {
                        UserService.shared.login(sessionId: sessionId, service: service, account: account, rpPublicKey: self?.rpPublicKey, custom: custom, completion: completion)
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
            guard let self = self else { return }

            switch result {
            case .success(let service):
                ApiService.shared.permissions(service: service, permissions: [.mobileSignUp]) { result in
                    switch result {
                    case .success(let permissions):
                        if permissions[.mobileSignUp] == true {
                            UserService.shared.mobileSignUp(username: username, service: service, callbackUrl: self.callbackUrl, custom: custom, extendedHeaders: extendedHeaders, completion: completion)
                        } else {
                            completion(.failure(KeyriErrors.serviceAccessDenied))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func mobileLogin(account: PublicAccount, custom: String?, extendedHeaders: [String: String]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        whitelabelInitIfNeeded { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let service):
                ApiService.shared.permissions(service: service, permissions: [.mobileLogin]) { result in
                    switch result {
                    case .success(let permissions):
                        if permissions[.mobileLogin] == true {
                            UserService.shared.mobileLogin(account: account, service: service, callbackUrl: self.callbackUrl, custom: custom, extendedHeaders: extendedHeaders, completion: completion)
                        } else {
                            completion(.failure(KeyriErrors.serviceAccessDenied))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func accounts(completion: @escaping (Result<[PublicAccount], Error>) -> Void) {
        whitelabelInitIfNeeded { result in
            switch result {
            case .success(let service):
//                ApiService.shared.permissions(service: service, permissions: [.accounts]) { result in
//                    switch result {
//                    case .success(let permissions):
//                        if permissions[.accounts] == true {
                            completion(.success(
                                StorageService.shared.getAllAccounts(serviceId: service.id).map { PublicAccount(username: $0.username, custom: $0.custom) }
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
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            fatalError(KeyriErrors.generic.errorDescription ?? "")
        }

        ApiService.shared.whitelabelInit(appKey: appkey, deviceId: deviceId) { result in
            completion(result)
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
