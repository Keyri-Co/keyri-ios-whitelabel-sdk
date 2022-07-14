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
    
    @objc public func initializeQrSession(username: String?, sessionId: String, appKey: String) -> Session? {
        var ret: Session?
        keyri.initializeQrSession(username: username, sessionId: sessionId, appKey: appKey) { result in
            switch result {
            case .success(let session):
                ret = session
            case .failure(let error):
                print(error)
            }
        }
        
        return ret
        
    }
    
    @objc public func generateAssociationKey(username: String) -> String? {
        do {
            return try keyri.generateAssociationKey(username: username).pemRepresentation
        } catch {
            return nil
        }
    }
    
    @objc public func generateUserSignature(username: String, data: Data) -> String? {
        do {
            return try keyri.generateUserSignature(for: username, data: data).derRepresentation.base64EncodedString()
        } catch {
            return nil
        }
    }
    
    @objc public func getAssociationKey(username: String) -> String? {
        do {
            return try keyri.getAssociationKey(username: username)?.pemRepresentation
        } catch {
            return nil
        }
    }
    
    @objc public func listAssociactionKeys() -> [String:String]? {
        return keyri.listAssociactionKeys()
    }
}
