//
//  Session.swift
//
//  Created by Aditya Malladi on 5/25/22.
//

import Foundation
import CryptoKit

public struct Session: Codable {
    // configure this variabla to set a custom payload to be sent to the browser
    public var payload: String?
    
    var WidgetUserAgent: WidgetUserAgent
    var IPAddressMobile: String
    var IPAddressWidget: String
    var riskAnalytics: RiskAnalytics?
    
    var userPublicKey: String?
    var userID: String?
    
    private var sessionId: String
    private var browserPublicKey: String
    private var __hash: String
    private var __salt: String
    
    
    public func deny() throws {
        do {
            try sendPOST(success: false)
        } catch {
            throw error
        }
    }
    
    public func confirm() throws {
        do {
            try sendPOST(success: true)
        } catch {
            throw error
        }
    }
    
    private func sendPOST(success: Bool) throws {
        let enc = EncryptionUtil()
        let keySet = enc.deriveKeys(from: browserPublicKey)
        guard let keySet = keySet else {
            return
        }
    
        
        let cipher = enc.encrypt(message: payload ?? "", with: keySet.0, salt: __salt)
        
        let json: [String: Any] = [
            "__salt": __salt,
            "__hash": __hash,
            "error": success.description,
            "errorMsg": "",
            "apiData": [
                "publicUserId": userID,
                "associationKey": userPublicKey
            ],
            "browserData": [
                "publicKey": keySet.1.rawRepresentation.base64EncodedString(),
                "ciphertext": cipher?.base64EncodedString(),
                "salt": __salt,
                "iv": keySet.1.rawRepresentation.base64EncodedString()
            ]
        ]
        
        let svc = KeyriService()
        do {
            try svc.postSuccessfulAuth(sessionId: sessionId, sessionInfo: json)
        } catch {
            throw error
        }
    }
    /*
     {
         "__salt": "dGhpcw==",
         "__hash": "dGhhdA==",
         "error": false,
         "errorMsg": "",
         "apiData" : {
             "publicUserId" : "hannibal@beyondmeat.com",
             "associationKey": "[base64String]",
         },
         "browserData": {
             "publicKey": "NE2deL6zi0nHG3UFadYNClzCM1Dfij9u8wTu3Z5ORZrowfqg8gE/2cKluz8sczmjI4iOxD6vkDo34/5ULCtVXA==",
             "ciphertext": "+OtK/5EnPMHYaYZAb7pjz9twyu5YUPUoPiBYZuVxTanscsnFw9C0BrgOXyt0CH9Axg==",
             "salt": "RHaIujn+jsd+po+aBYxZSg==",
             "iv": "hcFyHtcQEZmz4gKBb/XcaQ==",
         }
     }
     */
}
