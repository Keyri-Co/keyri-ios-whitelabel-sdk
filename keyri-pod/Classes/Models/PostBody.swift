//
//  PostBody.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 6/1/22.
//

import Foundation

public struct PostBody: Codable {
    public var __hash: String
    public var __salt: String
    public var error: String
    public var errorMsg: String
    public var apiData: apiData
    public var browserData: browserData
}

public struct apiData: Codable {
    public var publicUserId: String
    public var associationKey: String
}

public struct browserData: Codable {
    public var publicKey: String
    public var ciphertext: String
    public var salt: String
    public var iv: String
}


