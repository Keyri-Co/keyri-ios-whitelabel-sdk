//
//  LocationData.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 5/25/22.
//

import Foundation

public class LocationData: NSObject, Codable {
    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case city
        case continentCode = "continent_code"
        case regionCode = "region_code"
    }
    
    @objc public var countryCode: String?
    @objc public var city: String?
    @objc public var continentCode: String?
    @objc public var regionCode: String?
    
    
}
