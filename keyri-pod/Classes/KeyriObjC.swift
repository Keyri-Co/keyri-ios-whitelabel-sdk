//
//  KeyriObjC.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 7/13/22.
//

import Foundation

public class KeyriObjC: NSObject {
    var keyri: Keyri?
    
    @objc public override init() {
        keyri = nil
    }
    
    @objc public func initializeKeyri(appKey: String, publicAPIKey: String?) {
        keyri = Keyri(appKey: appKey, publicApiKey: publicAPIKey)
    }
    
    @objc public func easyKeyriAuth(publicUserId: String, payload: String, completion: @escaping ((Bool, Error?) -> ())) {
        guard let keyri = keyri else {
            completion(false, KeyriErrors.notInitializedError)
            return
        }
        
        keyri.easyKeyriAuth(publicUserId: publicUserId, payload: payload) { result in
            switch result {
            case .success(let bool):
                completion(bool, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }
    
    @objc public func processLink(url: URL, publicUserId: String, appKey: String, payload: String, completion: @escaping ((Bool, Error?) -> ())) {
        guard let keyri = keyri else {
            completion(false, KeyriErrors.notInitializedError)
            return
        }
        
        keyri.processLink(url: url, publicUserId: publicUserId, appKey: appKey, payload: payload) { result in
            switch result {
            case .success(let bool):
                completion(bool, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }
    
    @objc public func initiateQrSession(username: String?, sessionId: String, appKey: String, completion: @escaping ((Session?, Error?) -> ())) {
        guard let keyri = keyri else {
            completion(nil, KeyriErrors.notInitializedError)
            return
        }
        
        keyri.initiateQrSession(username: username, sessionId: sessionId) { result in
            switch result {
            case .success(let session):
                completion(session, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    @objc public func initializeDefaultConfirmationScreen(session: Session, payload: String,  completion: @escaping (Bool) -> ()) {
        guard let keyri = keyri else {
            completion(false)
            return
        }
        
        keyri.initializeDefaultConfirmationScreen(session: session, payload: payload, completion: completion)
    }
    
    @objc public func generateAssociationKey(username: String?) throws -> String {
        guard let keyri = keyri else {
            throw KeyriErrors.notInitializedError
        }
        
        if let username = username {
            return try keyri.generateAssociationKey(username: username).derRepresentation.base64EncodedString()
        } else {
            return try keyri.generateAssociationKey().derRepresentation.base64EncodedString()
        }
    }
    
    @objc public func generateUserSignature(username: String?, data: Data) throws -> String {
        guard let keyri = keyri else {
            throw KeyriErrors.notInitializedError
        }
        
        if let username = username {
            return try keyri.generateUserSignature(for: username, data: data).derRepresentation.base64EncodedString()
        } else {
            return try keyri.generateUserSignature(data: data).derRepresentation.base64EncodedString()
        }
    }
    
    @objc public func getAssociationKey(username: String?) throws -> String {
        guard let keyri = keyri else {
            throw KeyriErrors.notInitializedError
        }
        
        if let username = username, let associationKey = try keyri.getAssociationKey(username: username) {
            return associationKey.derRepresentation.base64EncodedString()
        } else if let associationKey = try keyri.getAssociationKey() {
            return associationKey.derRepresentation.base64EncodedString()
        } else {
            throw KeyriErrors.keyriSdkError
        }
    }
    
    @objc public func removeAssociationKey(publicUserId: String?) throws {
        guard let keyri = keyri else {
            throw KeyriErrors.notInitializedError
        }
        
        if let publicUserId = publicUserId {
            try keyri.removeAssociationKey(publicUserId: publicUserId)
        } else {
            try keyri.removeAssociationKey()
        }
    }
    
    @objc public func listAssociactionKeys() -> [String:String]? {
        guard let keyri = keyri else { return nil }
        return keyri.listAssociactionKeys()
    }
    
    @objc public func listUniqueAccounts() -> [String:String]? {
        guard let keyri = keyri else { return nil }
        return keyri.listUniqueAccounts()
    }
    
    public func sendEvent(username: String = "ANON", eventType: EventType = .visits, success: Bool = true, completion: @escaping (FingerprintResponse?, Error?) -> ()) throws {
        guard let keyri = keyri else { throw KeyriErrors.notInitializedError }
        return try keyri.sendEvent(username: username, eventType: eventType, success: success) { res in
            switch res {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    
}

