//
//  ApiService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation

public struct Session: Codable {
    public let service: Service
    public let isNewUser: Bool
    public let username: String?
}

public struct Service: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case logo
    }

    public let id: String
    public let name: String
    public let logo: String?
}

final class ApiService {
    static let shared = ApiService()
        
    private let baseUrl: String
    
    private init() {
        let config = Config()
        baseUrl = config.apiUrl
    }
    
    func getSession(sessionId: String, completion: @escaping ((Result<Session, Error>) -> Void)) {
        let task = URLSession.shared.dataTask(with: URL(string: "\(baseUrl)/api/session/\(sessionId)")!) {(data, response, error) in
            guard let data = data else {
                completion(.failure(KeyriErrors.generic))
                return
            }
            do {
                let session = try JSONDecoder().decode(Session.self, from: data)
                completion(.success(session))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
    func authMobile(url: URL, userId: String, username: String?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        var parameterDictionary = ["userId" : userId]
        if let username = username {
            parameterDictionary["username"] = username
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                        completion(.failure(KeyriErrors.generic))
                        return
                    }
                    completion(.success(json))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
