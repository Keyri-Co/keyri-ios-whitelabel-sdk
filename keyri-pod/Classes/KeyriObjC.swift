//
//  KeyriObjC.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 7/13/22.
//

import Foundation

public class KeyriObjC: NSObject {
    let keyri: Keyri
    
    @objc public override init() {
        keyri = Keyri()
    }
    
    @objc public func easyKeyriAuth(publicUserId: String, appKey: String, payload: String, completion: @escaping ((Bool) -> ())) {
        keyri.easyKeyriAuth(publicUserId: publicUserId, appKey: appKey, payload: payload) { bool in
            completion(bool)
        }
    }
    
    @objc public func processLink(url: URL, publicUserId: String, appKey: String, payload: String, completion: @escaping ((Bool) -> ())) {
        keyri.processLink(url: url, publicUserId: publicUserId, appKey: appKey, payload: payload) { bool in
            completion(bool)
        }
    }
    
    @objc public func initiateQrSession(username: String?, sessionId: String, appKey: String, completion: @escaping ((Session?, Error?) -> ())) {
        keyri.initiateQrSession(username: username, sessionId: sessionId, appKey: appKey) { result in
            switch result {
            case .success(let session):
                completion(session, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    @objc public func initializeDefaultConfirmationScreen(session: Session, payload: String,  completion: @escaping (Bool) -> ()) {
        keyri.initializeDefaultConfirmationScreen(session: session, payload: payload, completion: completion)
    }
    
    @objc public func generateAssociationKey(username: String?) -> String? {
        do {
            if let username = username {
                return try keyri.generateAssociationKey(username: username).derRepresentation.base64EncodedString()
            } else {
                return try keyri.generateAssociationKey().derRepresentation.base64EncodedString()
            }
        } catch {
            return nil
        }
    }
    
    @objc public func generateUserSignature(username: String?, data: Data) -> String? {
        do {
            if let username = username {
                return try keyri.generateUserSignature(for: username, data: data).derRepresentation.base64EncodedString()
            } else {
                return try keyri.generateUserSignature(data: data).derRepresentation.base64EncodedString()
            }
        } catch {
            return nil
        }
    }
    
    @objc public func getAssociationKey(username: String?) -> String? {
        do {
            if let username = username {
                return try keyri.getAssociationKey(username: username)?.derRepresentation.base64EncodedString()
            } else {
                return try keyri.getAssociationKey()?.derRepresentation.base64EncodedString()
            }
        } catch {
            return nil
        }
    }
    
    @objc public func removeAssociationKey(publicUserId: String?) {
        do {
            if let publicUserId = publicUserId {
                try keyri.removeAssociationKey(publicUserId: publicUserId)
            } else {
                try keyri.removeAssociationKey()
            }
        } catch {
            return
        }
    }
    
    @objc public func listAssociactionKeys() -> [String:String]? {
        return keyri.listAssociactionKeys()
    }
}
