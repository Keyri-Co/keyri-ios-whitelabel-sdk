//
//  FingerprintResponse.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 4/11/23.
//

import Foundation

public class FingerprintResponse: NSObject, Decodable {
    @objc public let data: Event?
    @objc public let result: Bool
    @objc public let error: FPError?
    
    private enum CodingKeys: String, CodingKey {
        case data
        case result
        case error
    }
}
