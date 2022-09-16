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
        
        guard let url = URL(string: "https://prod.api.keyri.com/api/v1/session/\(sessionId)?appKey=\(appKey)") else {
            completionHandler(.failure(KeyriErrors.keyriSdkError))
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
    
    
    public func postSuccessfulAuth(sessionId: String, sessionInfo: [String: Any]) throws {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sessionInfo)
            
            guard let url = URL(string: "https://prod.api.keyri.com/api/v1/session/\(sessionId)") else {
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
}
