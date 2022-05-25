//
//  KeyriService.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 5/16/22.
//

import Foundation

public class KeyriService {
    public func getSessionInfo(completionHandler: @escaping (Result<Data, Error>) -> Void) {
        
        let url = URL(string: "https://test.api.keyri.com/api/session/8681155258426265-1652798035078?appKey=IT7VrTQ0r4InzsvCNJpRCRpi1qzfgpaj")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("led")
                completionHandler(.failure(ErrorType.serverError))
                return
            }

            guard let data = data else {
                print("no")
                completionHandler(.failure(ErrorType.serverError))
                return
                
            }
            print(String(data: data, encoding: .utf8)!)
            completionHandler(.success(data))
        }

        task.resume()
        
    }
    
    
    public func postSuccessfulAuth(sessionInfo: SessionInfo) {
        
    }
}

public struct SessionInfo: Codable {
    private var sessionId: String
    private var publicKey: String
    private var __salt: String
    private var __hash: String
}
