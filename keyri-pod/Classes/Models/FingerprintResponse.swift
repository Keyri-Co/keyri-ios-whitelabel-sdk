//
//  FingerprintResponse.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 4/11/23.
//

import Foundation

public class FingerprintResponse: NSObject, Decodable {
    @objc let data: Event?
    @objc let result: Bool
    @objc let error: FPError?
    
    private enum CodingKeys: String, CodingKey {
        case data
        case result
        case error
    }
}
