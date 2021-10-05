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
        let bundle = Bundle(for: Keyri.self)
        #if DEBUG
        let path = bundle.path(forResource: "dev", ofType: "json")!
        #else
        let path = bundle.path(forResource: "prod", ofType: "json")!
        #endif
        
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
            let config = try JSONDecoder().decode(ConfigData.self, from: jsonData)
            
            apiUrl = config.apiUrl
            wsUrl = config.wsUrl
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
