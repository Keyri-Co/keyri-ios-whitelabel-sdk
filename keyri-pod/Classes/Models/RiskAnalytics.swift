///
//  RiskAnalytics.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 5/25/22.
//

import Foundation

public class RiskAnalytics: NSObject, Codable {
    @objc public var riskStatus: String?
    @objc public var riskFlagString: String?
    @objc public var geoData: GeoDataPair?
}

