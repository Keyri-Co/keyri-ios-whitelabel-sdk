//
//  Event.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 4/11/23.
//

public class Event: NSObject, Decodable {
    @objc public let applicationId: String?
    @objc public let createdAt: String?
    @objc public let event: String?
    @objc public let fingerprintId: String?
    @objc public let id: String?
    @objc public let ip: String?
    @objc public let location: FPLocation?
    @objc public let result: String?
    @objc public let riskParams: String?
    @objc public let signals: [String]?
    @objc public let updatedAt: String?
    @objc public let userId: String?
    
    private enum CodingKeys: String, CodingKey {
        case applicationId
        case createdAt
        case event
        case fingerprintId
        case id
        case ip
        case location
        case result
        case riskParams
        case signals
        case updatedAt
        case userId
    }
}
