//
//  KeyriService.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 5/16/22.
//

import Foundation

public class KeyriService {
    public func getSessionInfo(completionHandler: @escaping (Result<Data, Error>) -> Void) {
        
        let url = URL(string: "https://prod.api.keyri.com/api/session/2622074828-1654093096044-0-f3wci1qsqs?appKey=IT7VrTQ0r4InzsvCNJpRCRpi1qzfgpaj")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("led")
                completionHandler(.failure(error!))
                return
            }

            guard let data = data else {
                print("no")
                completionHandler(.failure(error!))
                return
                
            }
            print(String(data: data, encoding: .utf8)!)
            completionHandler(.success(data))
        }

        task.resume()
        
    }
    
    
    public func postSuccessfulAuth(sessionInfo: [String: Any]) throws {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sessionInfo)
            
            let url = URL(string: "http://httpbin.org/post")!
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
