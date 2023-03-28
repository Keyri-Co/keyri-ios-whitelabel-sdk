//
//  KeyriService.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 5/16/22.
//

import Foundation
import CryptoKit

public class KeyriService {
    public func getSessionInfo(appKey: String, sessionId: String, associationKey: P256.Signing.PublicKey, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        
        let prefix = urlPrefix(from: appKey)
        guard let url = URL(string: "https://\(prefix).api.keyri.com/api/v1/session/\(sessionId)?appKey=\(appKey)") else {
            completionHandler(.failure(KeyriErrors.keyriSdkError))
            return
        }
        
        guard EPDUtil.isEPD() else {
            TelemetryService.sendEvent(status: .failure, code: .epdDetected, message: "EPD on GET", sessionId: sessionId)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(associationKey.derRepresentation.base64EncodedString(), forHTTPHeaderField: "x-mobile-id")
        request.addValue(UIDevice.current.identifierForVendor?.description ?? "", forHTTPHeaderField: "x-mobile-vendorId")
        request.addValue("iOS", forHTTPHeaderField: "x-mobile-os")
        
        TelemetryService.sendEvent(status: .success, code: .getTriggered, message: "Sending GET", sessionId: sessionId)

        let task = URLSession.shared.dataTask(with: request) {(data, _, error) in
            guard let data = data else {
                completionHandler(.failure(KeyriErrors.networkError))
                TelemetryService.sendEvent(status: .failure, code: .getResponseHandled, message: KeyriErrors.networkError.localizedDescription, sessionId: sessionId)
                return
                
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
            
            TelemetryService.sendEvent(status: .success, code: .getResponseHandled, message: data.base64EncodedString(), sessionId: sessionId)
            completionHandler(.success(data))
        }

        task.resume()
        
    }
    
    
    public func postSuccessfulAuth(sessionId: String, sessionInfo: [String: Any], appKey: String) throws {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sessionInfo)
            
            let prefix = urlPrefix(from: appKey)
            
            guard let url = URL(string: "https://\(prefix).api.keyri.com/api/v1/session/\(sessionId)") else {
                throw KeyriErrors.keyriSdkError
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            // insert json data to the request
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    TelemetryService.sendEvent(status: .failure, code: .postResponseReceived, message: "Failed to POST", sessionId: sessionId)
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                }
                
                TelemetryService.sendEvent(status: .success, code: .postResponseReceived, message: "POST success", sessionId: sessionId)
            }

            task.resume()
            TelemetryService.sendEvent(status: .success, code: .postSent, message: "Sent POST", sessionId: sessionId)
        } catch {
            throw error
        }
    }
    
    public func createDevice(appKey: String, dict: [String: Any]) -> Bool {
        print("HELLO")

        var url = ""
        if appKey == "raB7SFWt27VoKqkPhaUrmWAsCJIO8Moj" || appKey == "development_FE2fZlpOwydIcvlGGg3vtLJMCDvweuPe" {
            print("dev")
            url = "https://dev-api.keyri.co/fingerprint/new-device"
        } else {
            url = "https://api.keyri.co/fingerprint/new-device"
        }
        
        print(dict)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            print(jsonData)
            guard let url = URL(string: url) else {
                throw KeyriErrors.keyriSdkError
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue(appKey, forHTTPHeaderField: "api-key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            // insert json data to the request
            request.httpBody = jsonData as Data

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                print("response")
                guard let data = data, error == nil else {

                    print(error?.localizedDescription ?? "No data")
                    return
                }
                
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                }
            }

            task.resume()
            
            
            
            
            
        } catch {
            print(error)
            return false
        }
        return false
    }
    
    public func sendEvent(appKey: String, username: String = "ANON", eventType: String = "Default", success: Bool = true) {
        
        guard let url = URL(string: "https://dev-api.keyri.co/fingerprint/event") else { return }
        guard let associationKey = try? Keyri().getAssociationKey(username: username) else { return }
        
        var request = URLRequest(url: url)
        
        request.addValue(associationKey.rawRepresentation.base64EncodedString(), forHTTPHeaderField: "cryptocookie")
        request.addValue(String(SHA256.hash(data: associationKey.rawRepresentation).description.split(separator: " ")[2]), forHTTPHeaderField: "devicehash")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(appKey, forHTTPHeaderField: "api-key")
        request.httpMethod = "POST"
        
        let dict = [
          "eventType": "login",
          "eventResult": "success",
          "signals": [],
          "userId": "user34",
          "userEmail": "user34"
        ] as [String : Any]
        
        guard let json = try? JSONSerialization.data(withJSONObject: dict) else { return }
        
        request.httpBody = json
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {

                print(error?.localizedDescription ?? "No data")
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }

        task.resume()
        
        
        
    }
    
    private func urlPrefix(from appKey: String) -> String {
        guard let data = appKey.data(using: .utf8) else { return "prod" }
        let hash = SHA256.hash(data: data).hashValue
        
        if hash == -7517014640307154636 { return "dev" }
        else if hash == -285964041080602815 { return "test" }
        
        return "prod"

    }
}
