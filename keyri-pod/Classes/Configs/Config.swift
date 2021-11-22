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
    }
    
    let apiUrl: String
    let wsUrl: String
}

struct Config {
    let apiUrl: String
    let wsUrl: String
    
    init() {
        #if DEBUG
        let jsonData = Self.prodRawConfig.data(using: .utf8)
        #else
        let jsonData = Self.prodRawConfig.data(using: .utf8)
        #endif
        
        guard let jsonData = jsonData else {
            fatalError(KeyriErrors.wrongConfigError.localizedDescription)
        }

        do {
            let config = try JSONDecoder().decode(ConfigData.self, from: jsonData)

            apiUrl = config.apiUrl
            wsUrl = config.wsUrl
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
            }
        """
    }
    
    static var prodRawConfig: String {
        """
            {
                "API_URL": "https://api.keyri.co",
                "WS_URL": "https://api.keyri.co"
            }
        """
    }
}
