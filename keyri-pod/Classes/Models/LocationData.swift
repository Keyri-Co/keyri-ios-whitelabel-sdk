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
    }
    
    @objc var countryCode: String?
    @objc var city: String?
}
