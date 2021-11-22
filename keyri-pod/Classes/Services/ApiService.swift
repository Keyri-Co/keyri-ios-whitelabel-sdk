//
//  ApiService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation

public class Session: NSObject, Codable {
    public let service: Service
    public let isNewUser: Bool
    public let username: String?
}

public class Service: NSObject, Codable {
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
        
    private let baseUrl: String
    
    let service: Service
    
    init(service: Service) {
        let config = Config()
        baseUrl = config.apiUrl
        self.service = service
    }
    
    static func handleResponseStatusCode(_ response: URLResponse?) -> Error? {
        guard let response = response as? HTTPURLResponse else { return nil }
        switch response.statusCode {
        case 400...499:
            return KeyriErrors.serverError
        case 500...599:
            return KeyriErrors.internalServerError
        default:
            return nil
        }
    }
    
    func getSession(sessionId: String, completion: @escaping ((Result<Session, Error>) -> Void)) {
        guard let url = URL(string: "\(baseUrl)/api/session/\(sessionId)") else {
            completion(.failure(KeyriErrors.networkError))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                let _error = Self.handleResponseStatusCode(response) ?? error ?? KeyriErrors.networkError
                print(_error.localizedDescription)
                completion(.failure(_error))
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
    
    func authMobile(url: URL, userId: String, username: String?, clientPublicKey: String?, extendedHeaders: [String: String]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        var parameterDictionary = ["userId": userId]
        if let username = username {
            parameterDictionary["username"] = username
            parameterDictionary["clientPublicKey"] = clientPublicKey
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        extendedHeaders?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
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
                        completion(.failure(KeyriErrors.authorizationError))
                        return
                    }
                    completion(.success(json))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(KeyriErrors.authorizationError))
            }
        }.resume()
    }
    
    static func whitelabelInit(appKey: String, deviceId: String, completion: @escaping ((Result<ApiService, Error>) -> Void)) {
        let baseUrl = Config().apiUrl
        guard let url = URL(string: "\(baseUrl)/api/sdk/whitelabel-init") else {
            completion(.failure(KeyriErrors.networkError))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let parameterDictionary = ["mobileAppKey": appKey, "device_id": deviceId]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            assertionFailure("Invalid parameters in auth mobile request")
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(WhitelabelInitResponse.self, from: data)
                    completion(.success(ApiService(service: response.service)))
                } catch {
                    completion(.failure(error))
                }
            } else {
                let _error = Self.handleResponseStatusCode(response) ?? error ?? KeyriErrors.networkError
                print(_error.localizedDescription)
                completion(.failure(_error))
            }
        }.resume()
    }
    
    func permissions(service: Service, permissions: [Permissions], completion: @escaping ((Result<[Permissions: Bool], Error>) -> Void)) {
        var components = URLComponents(string: "\(baseUrl)/service/\(service.id)/permissions")
        var queryItems: [URLQueryItem] = []
        permissions.forEach { queryItems.append(URLQueryItem(name: "queryPermissions", value: $0.rawValue)) }
        components?.queryItems = queryItems
        guard let permissionsUrl = components?.url else {
            completion(.failure(KeyriErrors.networkError))
            return
        }
        
        let task = URLSession.shared.dataTask(with: permissionsUrl) { data, response, error in
            guard let data = data else {
                let _error = Self.handleResponseStatusCode(response) ?? error ?? KeyriErrors.networkError
                print(_error.localizedDescription)
                completion(.failure(_error))
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(.failure(KeyriErrors.networkError))
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
