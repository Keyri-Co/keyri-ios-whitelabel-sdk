//
//  Errors.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 5/25/22.
//

import Foundation

enum KeyriErrors: LocalizedError {
    case keyriSdkError
    case networkError
    case serverUnreachableError
    case internalServerError
    case serverError
    case notInitializedError
    case wrongConfigError
    case accountNotFoundError
    case multipleAccountsNotAllowedError
    case permissionsError
    case authorizationError
    case iOSInternalError
    
    var errorDescription: String? {
        switch self {
        case .keyriSdkError:
            return "Basic SDK Error"
        case .networkError:
            return "No internet connection"
        case .serverUnreachableError:
            return "Server is unreachable"
        case .internalServerError:
            return "Internal server error"
        case .serverError:
            return "Internal server error. Service is unreachable"
        case .notInitializedError:
            return "Keyri SDK is not initialized"
        case .wrongConfigError:
            return "New service id doesn't match with current"
        case .accountNotFoundError:
            return "The account that makes the login was not found"
        case .multipleAccountsNotAllowedError:
            return "Multiple accounts not allowed"
        case .permissionsError:
            return "Permissions are not granted"
        case .authorizationError:
            return "Unable to authorize"
        case .iOSInternalError:
            return "iOS Error"
        }
    }
}
