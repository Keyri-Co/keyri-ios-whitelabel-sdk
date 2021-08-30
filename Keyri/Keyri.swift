//
//  Keyri.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 25.08.2021.
//

import Foundation
import Sodium

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

public final class Keyri {
    var id: String?
    var name: String?
    var callbackUrl: URL?
    var logoUrl: URL?
    
    public static let shared = Keyri()
    
    private init() {}
    
    public func initialize(id: String, name: String, callbackUrl: URL, logoUrl: URL) {
        self.id = id
        self.name = name
        self.callbackUrl = callbackUrl
        self.logoUrl = logoUrl
        
        let _ = KeychainService.shared.getCryptoBox()
    }
                        
    public func onReadSessionId(_ sessionId: String, completion: @escaping (Result<Session, Error>) -> Void) {
        ApiService.shared.getSession(sessionId: sessionId) { result in
            switch result {
            case .success(let session):
                print(session)
                completion(.success(session))
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    public func signUp(username: String, sessionId: String, service: Service, custom: String?) {
        UserService.shared.signUp(username: username, sessionId: sessionId, service: service, custom: custom)
    }
    
    public func login(sessionId: String, service: Service, account: PublicAccount, custom: String?) {
        UserService.shared.login(sessionId: sessionId, service: service, account: account, custom: custom)
    }
    
    public func mobileLogin(account: PublicAccount, custom: String?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let id = id, let logoUrl = logoUrl, let name = name else {
            return
        }
        UserService.shared.mobileLogin(account: account, service: Service(id: id, name: name, logo: logoUrl.absoluteString), callbackUrl: callbackUrl, custom: custom, completion: completion)
    }
    
    public func mobileSignUp(username: String, custom: String?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let id = id, let logoUrl = logoUrl, let name = name else {
            return
        }
        UserService.shared.mobileSignUp(username: username, service: Service(id: id, name: name, logo: logoUrl.absoluteString), callbackUrl: callbackUrl, custom: custom, completion: completion)
    }
    
    public func accounts() -> [PublicAccount] {
        guard let id = id else {
            return []
        }
        return StorageService.shared.getAllAccounts(serviceId: id).map { PublicAccount(username: $0.username, custom: $0.custom) }
    }
}
