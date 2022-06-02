///
//  RiskAnalytics.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 5/25/22.
//

import Foundation

public struct RiskAnalytics: Codable {
    //var riskAttributes: RiskAttributes
    var riskStatus: String
    var riskFlagString: String
    var geoData: GeoDataPair?
}
