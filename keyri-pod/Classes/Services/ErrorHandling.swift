//
//  ErrorHandling.swift
//  Keyri
//
//  Created by Andrii Novoselskyi on 28.08.2021.
//

import Foundation

enum KeyriErrors: LocalizedError {
    case generic
    case accountNotFound
    case accountCreationFails
    case sessionNotFound
    case socketInitializationFails
    case socketEmitionFails
    case serviceAccessDenied
    case identifierForVendorNotFound
    
    var errorDescription: String? {
        switch self {
        case .generic:
            return "Generic"
        case .accountNotFound:
            return "Account not found"
        case .accountCreationFails:
            return "Account creation fails"
        case .sessionNotFound:
            return "Session not found"
        case .socketInitializationFails:
            return "Socket initialization fails"
        case .socketEmitionFails:
            return "Socket emition fails"
        case .serviceAccessDenied:
            return "Service access denied"
        case .identifierForVendorNotFound:
            return "Identifier for vendor not found"
        }
    }
}
