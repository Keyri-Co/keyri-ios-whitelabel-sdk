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

private struct WhitelabelInitResponse: Codable {
    let token: String
    let service: Service
}

final class ApiService {
    enum Permissions: String {
        case getSession
        case signUp
        case login
        case mobileLogin
        case mobileSignUp
        case accounts
    }
    
    static let shared = ApiService()
        
    private let baseUrl: String
    
    private var service: Service?
    
    private init() {
        let config = Config()
        baseUrl = config.apiUrl
    }
    
    func getSession(sessionId: String, completion: @escaping ((Result<Session, Error>) -> Void)) {
        let task = URLSession.shared.dataTask(with: URL(string: "\(baseUrl)/api/session/\(sessionId)")!) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "")
                completion(.failure(KeyriErrors.sessionNotFound))
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
        var parameterDictionary = ["userId": userId]
        if let username = username {
            parameterDictionary["username"] = username
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            assertionFailure("Invalid parameters in auth mobile request")
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
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
    
    func whitelabelInit(appKey: String, deviceId: String, completion: @escaping ((Result<Service, Error>) -> Void)) {
        guard let service = service else {
            var request = URLRequest(url: URL(string: "\(baseUrl)/api/sdk/whitelabel-init")!)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            let parameterDictionary = ["mobileAppKey": appKey, "device_id": deviceId]
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
                assertionFailure("Invalid parameters in auth mobile request")
                return
            }
            request.httpBody = httpBody
            
            let session = URLSession.shared
            session.dataTask(with: request) { [weak self] data, response, error in
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(WhitelabelInitResponse.self, from: data)
                        self?.service = response.service
                        completion(.success(response.service))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }.resume()
            return
        }
        
        completion(.success(service))
    }
    
    func permissions(service: Service, permissions: [Permissions], completion: @escaping ((Result<[Permissions: Bool], Error>) -> Void)) {
        var components = URLComponents(string: "\(baseUrl)/service/\(service.id)/permissions")
        var queryItems: [URLQueryItem] = []
        permissions.forEach { queryItems.append(URLQueryItem(name: "queryPermissions", value: $0.rawValue)) }
        components?.queryItems = queryItems
        guard let permissionsUrl = components?.url else {
            completion(.failure(KeyriErrors.serviceAccessDenied))
            return
        }
        
        let task = URLSession.shared.dataTask(with: permissionsUrl) { data, response, error in
            guard let data = data else {
                completion(.failure(KeyriErrors.serviceAccessDenied))
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(.failure(KeyriErrors.serviceAccessDenied))
                    return
                }
                var results: [Permissions: Bool] = [:]
                permissions.forEach { results[$0] = json[$0.rawValue] as? Bool ?? false }
                completion(.success(results))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
