//
//  ErrorHandling.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation

enum KeyriErrors: LocalizedError {
    case keyriSdkError
    case networkError
    case serverUnreachable
    case internalServerError
    case serverError
    case illegalState
    case notInitialized
    case wrongConfig
    case accountNotFound
    case multipleAccountsNotAllowed
    
    var errorDescription: String? {
        switch self {
        case .keyriSdkError:
            return "Basic SDK Error"
        case .networkError:
            return "No internet connection"
        case .serverUnreachable:
            return "Server is unreachable"
        case .internalServerError:
            return "Internal server error"
        case .serverError:
            return "Internal server error. Service is unreachable"
        case .illegalState:
            return "Service is nill"
        case .notInitialized:
            return "Keyri SDK is not initialized"
        case .wrongConfig:
            return "New service id doesn't match with current"
        case .accountNotFound:
            return "The account that makes the login was not found"
        case .multipleAccountsNotAllowed:
            return "Multiple accounts not allowed"
        }
    }
}
