//
//  ApiService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation

public class Session: NSObject, Codable {
    @objc public let service: Service
    @objc public let isNewUser: Bool
    @objc public let username: String?
    @objc public let widgetIPData: IPData?
    @objc public let mobileIPData: IPData?
    @objc public let sessionType: String?
    @objc public let custom: String?
}

public class Domain: NSObject, Codable {
    @objc public let domainName: String?
    @objc public let verifiedRecord: String?
    @objc public var isDomainApproved: Bool = false
}

public class IPData: NSObject, Codable {
    public class Asn: NSObject, Codable {
        @objc public let asn: String?
        @objc public let name: String?
        @objc public let domain: String?
        @objc public let route: String?
        @objc public let type: String?
    }
    
    public class Language: NSObject, Codable {
        @objc public let name: String?
        @objc public let native: String?
        @objc public let code: String?
    }
    
    public class Currency: NSObject, Codable {
        @objc public let name: String?
        @objc public let code: String?
        @objc public let symbol: String?
        @objc public let native: String?
        @objc public let plural: String?
    }
    
    public class TimeZone: NSObject, Codable {
        @objc public let name: String?
        @objc public let abbr: String?
        @objc public let offset: String?
        @objc public var is_dst: Bool = false
        @objc public let current_time: String?
    }
    
    public class Threat: NSObject, Codable {
        @objc public let is_tor: Bool
        @objc public let is_proxy: Bool
        @objc public let is_anonymous: Bool
        @objc public let is_known_attacker: Bool
        @objc public let is_known_abuser: Bool
        @objc public let is_threat: Bool
        @objc public let is_bogon: Bool
    }
    
    @objc public let ip: String?
    @objc public let is_eu: Bool
    @objc public let city: String?
    @objc public let region: String?
    @objc public let region_code: String?
    @objc public let country_name: String?
    @objc public let country_code: String?
    @objc public let continent_name: String?
    @objc public let continent_code: String?
    @objc public let latitude: Float
    @objc public let longitude: Float
    @objc public let postal: String?
    @objc public let calling_code: String?
    @objc public let flag: String?
    @objc public let emoji_flag: String?
    @objc public let emoji_unicode: String?
    @objc public let count: String?
    @objc public var status: Int
    @objc public let asn: Asn?
    @objc public let languages: [Language]?
    @objc public let currency: Currency?
    @objc public let time_zone: TimeZone?
    @objc public let threat: Threat?
}

public class Service: NSObject, Codable {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case logo
        case isValid
        case createdAt
        case updatedAt
        case ironPlansUUID
        case qrLogo
        case qrCodeType
        case subDomainName
        case originalDomain
    }

    @objc public let id: String
    @objc public let name: String
    @objc public let logo: String?
    @objc public var isValid: Bool
    @objc public var createdAt: String?
    @objc public var updatedAt: String?
    @objc public var ironPlansUUID: String?
    @objc public var qrLogo: String?
    @objc public var qrCodeType: String?
    @objc public var subDomainName: String?
    @objc public var originalDomain: Domain?

    @objc
    public init(id: String, name: String, logo: String?) {
        self.id = id
        self.name = name
        self.logo = logo
        self.isValid = true
        
        super.init()
    }
}

public class AuthMobileResponse: NSObject, Codable {
    @objc public let token: String
    @objc public let refreshToken: String
    @objc public let keyriUserId: String
    @objc public let user: AuthMobileUser
    
    public override var description: String {
        let dictionary = [
            "token": token,
            "refreshToken": refreshToken,
            "keyriUserId": keyriUserId,
            "user": user.description
        ]
        return dictionary.description
    }
}

public class AuthMobileUser: NSObject, Codable {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case createdAt
        case updatedAt
    }

    @objc public let id: String
    @objc public let name: String
    @objc public let createdAt: String
    @objc public let updatedAt: String
    
    public override var description: String {
        let dictionary = [
            "id": id,
            "name": name,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
        ]
        return dictionary.description
    }
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
    let config: Config
    
    init(service: Service, config: Config) {
        self.config = config
        self.service = service
        
        baseUrl = config.apiUrl
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
    
    func authMobile(url: URL, userId: String, username: String?, clientPublicKey: String?, extendedHeaders: [String: String]? = nil, completion: @escaping (Result<AuthMobileResponse, Error>) -> Void) {
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
            Assertion.failure("Invalid parameters in auth mobile request")
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(AuthMobileResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(KeyriErrors.authorizationError))
            }
        }.resume()
    }
    
    static func whitelabelInit(appKey: String, deviceId: String, completion: @escaping ((Result<ApiService, Error>) -> Void)) {
        let config = Config(appKey: appKey)
        let baseUrl = config.apiUrl
        guard let url = URL(string: "\(baseUrl)/api/sdk/whitelabel-init") else {
            completion(.failure(KeyriErrors.networkError))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let parameterDictionary = ["mobileAppKey": appKey, "device_id": deviceId]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            Assertion.failure("Invalid parameters in auth mobile request")
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(WhitelabelInitResponse.self, from: data)
                    completion(.success(ApiService(service: response.service, config: config)))
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
