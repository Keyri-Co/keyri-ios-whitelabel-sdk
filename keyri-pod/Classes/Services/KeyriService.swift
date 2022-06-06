//
//  KeyriService.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 5/16/22.
//

import Foundation

public class KeyriService {
    public func getSessionInfo(appKey: String, sessionId: String, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        
        guard let url = URL(string: "https://prod.api.keyri.com/api/session/\(sessionId)?appKey=\(appKey)") else {
            completionHandler(.failure(KeyriErrors.keyriSdkError))
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, _, error) in
            guard let data = data else {
                completionHandler(.failure(KeyriErrors.networkError))
                return
                
            }

            completionHandler(.success(data))
        }

        task.resume()
        
    }
    
    
    public func postSuccessfulAuth(sessionId: String, sessionInfo: [String: Any]) throws {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sessionInfo)
            
            guard let url = URL(string: "https://prod.api.keyri.com/api/session/\(sessionId)") else {
                throw KeyriErrors.keyriSdkError
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            // insert json data to the request
            request.httpBody = jsonData

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
        } catch {
            throw error
        }
    }
}
