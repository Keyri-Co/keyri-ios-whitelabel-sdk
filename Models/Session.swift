//
//  Session.swift
//  CryptoSwift
//
//  Created by Aditya Malladi on 5/25/22.
//

import Foundation

struct Session: Codable {
    var WidgetUserAgent: WidgetUserAgent
    var IPAddressMobile: String
    var IPAddressWidget: String
    var riskAnalytics: RiskAnalytics
    
    private var sessionId: String
    private var browserPublicKey: String
    private var __hash: String
    private var __salt: String
    
}
