//
//  Config.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation

struct ConfigData: Decodable {
    enum CodingKeys: String, CodingKey {
        case apiUrl = "API_URL"
        case wsUrl = "WS_URL"
        case ivAes = "IV_AES"
    }
    
    let apiUrl: String
    let wsUrl: String
    let ivAes: String
}

struct Config {
    let apiUrl: String
    let wsUrl: String
    let ivAes: String
    
    private let appKey: String?
    
    init(appKey: String?) {
        self.appKey = appKey
        
        let jsonData: Data?
        if appKey?.hasPrefix("dev") == true {
            jsonData = Self.devRawConfig.data(using: .utf8)
        } else {
            jsonData = Self.prodRawConfig.data(using: .utf8)
        }
        
        guard let jsonData = jsonData else {
            fatalError(KeyriErrors.wrongConfigError.localizedDescription)
        }

        do {
            let config = try JSONDecoder().decode(ConfigData.self, from: jsonData)

            apiUrl = config.apiUrl
            wsUrl = config.wsUrl
            ivAes = config.ivAes
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

extension Config {
    static var devRawConfig: String {
        """
            {
                "API_URL": "https://dev-api.keyri.co",
                "WS_URL": "wss://dev-api.keyri.co",
                "IV_AES": "wZJmSGa5cdCkgpMlG3/2Bg==",
            }
        """
    }
    
    static var prodRawConfig: String {
        """
            {
                "API_URL": "https://api.keyri.co",
                "WS_URL": "https://api.keyri.co",
                "IV_AES": "wZJmSGa5cdCkgpMlG3/2Bg==",
            }
        """
    }
}
