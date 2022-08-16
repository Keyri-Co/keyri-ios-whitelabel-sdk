//
//  Session.swift
//
//  Created by Aditya Malladi on 5/25/22.
//

import Foundation
import CryptoKit

public class Session: NSObject, Codable {
    enum CodingKeys: String, CodingKey {
        case payload
        
        case widgetOrigin    = "WidgetOrigin"
        case widgetUserAgent = "WidgetUserAgent"
        case iPAddressMobile = "IPAddressMobile"
        case iPAddressWidget = "IPAddressWidget"
        case riskAnalytics
        
        case userPublicKey
        case publicUserId
        
        case userParameters
        
        case sessionId
        case browserPublicKey
        case __hash
        case __salt
        
    }
    
    
    // configure this variabla to set a custom payload to be sent to the browser
    @objc public var payload: String?
    
    @objc var widgetOrigin: String?
    @objc var widgetUserAgent: WidgetUserAgent
    @objc var iPAddressMobile: String
    @objc var iPAddressWidget: String
    @objc var riskAnalytics: RiskAnalytics?
    
    @objc var userPublicKey: String?
    @objc public var publicUserId: String?
    
    @objc var userParameters: UserParameters?
    
    @objc public var sessionId: String
    private var browserPublicKey: String
    private var __hash: String
    private var __salt: String
    
    
    @objc public func deny() -> String {
        do {
            try sendPOST(denial: true)
            return "success"
        } catch {
            return error.localizedDescription
        }
    }
    
    @objc public func confirm() -> String {
        do {
            try sendPOST(denial: false)
            return "success"
        } catch {
            return error.localizedDescription
        }
    }
    
    private func sendPOST(denial: Bool) throws {
        let enc = EncryptionUtil()
        let keySet = enc.deriveKeys(from: browserPublicKey)
        guard let keySet = keySet else {
            return
        }
    
        let salt = Int.random(in: 0...9999).description
        
        let cipher = enc.encrypt(message: payload ?? "", with: keySet.0, salt: salt)
        print("\nENCRYPTED DATA::")
        let cipherData = cipher?.combined
        let cipherTruncated = cipherData?.dropFirst(12)
        
        
        
        let pubkey = keySet.1.rawRepresentation.base64EncodedString()
        print(pubkey)

        
        let json: [String: Any] = [
            "__salt": __salt,
            "__hash": __hash,
            "errors": denial == true ? true : false,
            "errorMsg": "",
            "apiData": [
                "publicUserId": publicUserId,
                "associationKey": userPublicKey
            ],
            "browserData": [
                "publicKey": pubkey,
                "ciphertext": cipherTruncated?.base64EncodedString(),
                "salt": salt.data(using: .utf8)!.base64EncodedString(),
                "iv": cipher?.nonce.withUnsafeBytes({ Data(Array($0)).base64EncodedString() })
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

