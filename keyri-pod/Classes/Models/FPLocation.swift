//
//  FPLocation.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 4/11/23.
//

public class FPLocation: NSObject, Decodable {
    @objc let city: String
    @objc let continentCode: String
    @objc let continentName: String
    @objc let country: String
    @objc let countryCode: String
    @objc let latitude: Double
    @objc let longitude: Double
    @objc let region: String
    @objc let regionCode: String
    @objc let regionType: String
    
    private enum CodingKeys: String, CodingKey {
        case city
        case continentCode = "continent_code"
        case continentName = "continent_name"
        case country
        case countryCode = "countryCode"
        case latitude
        case longitude
        case region
        case regionCode = "regionCode"
        case regionType = "regionType"
    }
}



