//
//  StorageService.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation

struct UserServiceData: Codable {
    var service: Service
    var accounts: [String: Account]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        service = try container.decode(Service.self, forKey: .service)
        accounts = (try? container.decode([String: Account].self, forKey: .accounts)) ?? [:]
    }
    
    init(service: Service) {
        self.service = service
        accounts = [:]
    }
}

struct Account: Codable {
    let userId: String
    let username: String
    let custom: String?
}

public struct PublicAccount {
    let username: String
    let custom: String?
}

final class StorageService {
    static let shared = StorageService()
    private init() {}
    
    private let storage = UserDefaults.standard
        
    func set(service: Service) {
        let userServiceData = UserServiceData(service: service)
        createOrUpdate(userServiceData: userServiceData)
    }
    
    func getService(serviceId: String) -> UserServiceData? {
        if let serviceData = storage.object(forKey: serviceId) as? Data {
            let decoder = JSONDecoder()
            return try? decoder.decode(UserServiceData.self, from: serviceData)
        }
        
        return nil
    }
    
    func add(account: Account, serviceId: String) {
        guard var userServiceData = getService(serviceId: serviceId) else {
            fatalError(KeyriErrors.generic.localizedDescription)
        }
        
        userServiceData.accounts[account.userId] = account
        createOrUpdate(userServiceData: userServiceData)
    }
        
    func remove(account: Account, from service: Service) {
        guard var userServiceData = getService(serviceId: service.id) else {
            fatalError(KeyriErrors.generic.localizedDescription)
        }
        userServiceData.accounts[account.userId] = nil
        createOrUpdate(userServiceData: userServiceData)
    }
    
    func getAllAccounts(serviceId: String) -> [Account] {
        guard let userServiceData = getService(serviceId: serviceId) else {
            fatalError(KeyriErrors.generic.localizedDescription)
        }
        return Array(userServiceData.accounts.values)
    }
}

extension StorageService {
    private func createOrUpdate(userServiceData: UserServiceData) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(userServiceData) {
            storage.set(encoded, forKey: userServiceData.service.id)
        }
    }
}
