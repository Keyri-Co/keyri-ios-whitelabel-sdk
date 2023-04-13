//
//  FPError.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 4/11/23.
//

public class FPError: NSObject, Decodable {
    @objc public let message: String
    
    private enum CodingKeys: String, CodingKey {
        case message
    }
}
