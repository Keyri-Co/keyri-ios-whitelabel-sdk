//
//  TelemetryManager.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 9/1/22.
//

import Foundation

public class TelemetryService {
    public static func sendEvent(status: EventStatus, code: EventCode, message: String, sessionId: String) {
        let deviceID = UIDevice.current.identifierForVendor
        let sysVersion = UIDevice.current.systemVersion
        let sdkVersion = ""
        let os = "iOS"
        
        guard let url = URL(string: "https://prod.api.keyri.com/api/logs/iOS/events") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let json: [String: String] = ["OS": sysVersion,
                                      "Platform": os,
                                      "sdkVersion": sdkVersion,
                                      "deviceID": deviceID?.description ?? "",
                                      "status": status.rawValue,
                                      "message": message
                                   ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else { return }
        request.httpBody = jsonData

        request.setValue(sessionId, forHTTPHeaderField: "x-session-id")
        request.setValue("iOS", forHTTPHeaderField: "x-mobile-os")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(data)
            }
            
            if let response = response {
                print("SENT TO TELEMETRY: \(message)")
                print(response)
            }
            
            if let error = error {
                print("FAILED TO SEND: \(message)")
                print(error)
            }
        }

        task.resume()

    }
}

public enum EventStatus: String {
    case success
    case failure
}

public enum EventCode {
    case scannerLaunched
    case scannerClosed
    case getTriggered
    case epdDetected
    case getResponseHandled
    case confirmationScreenLaunched
    case confirmationScreenDismissed
    case browserPublicKeyDerived
    case keyExchangeSucceeded
    case payloadEncrypted
    case postSent
    case postResponseReceived
    case failedToSaveKey
    case associationKeySaved
    case associationKeyQueried
    case edcsaDataSigned
    case associationKeyDeleted
}
