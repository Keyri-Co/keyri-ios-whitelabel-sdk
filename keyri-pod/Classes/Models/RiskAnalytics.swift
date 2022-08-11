///
//  RiskAnalytics.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 5/25/22.
//

import Foundation

public class RiskAnalytics: NSObject, Codable {
    //var riskAttributes: RiskAttributes
    @objc var riskStatus: String?
    @objc var riskFlagString: String?
    @objc var geoData: GeoDataPair?
}

