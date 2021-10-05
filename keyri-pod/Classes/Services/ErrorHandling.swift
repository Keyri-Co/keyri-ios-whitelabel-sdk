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
    case sessionNotFound
    case socketInitializationFails
    case socketEmitionFails
    case serviceAccessDenied
}
