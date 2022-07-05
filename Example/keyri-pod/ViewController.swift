//
//  ViewController.swift
//  KeyriExample
//
//  Created by Andrii Novoselskyi on 25.08.2021.
//

import UIKit
import AVFoundation
import keyri_pod
import Toaster

class ViewController: UIViewController {
    @IBAction func auth(_ sender: Any) {
        print("calling scanner")
        let scanner = keyri_pod.Scanner()
        scanner.completion = { str in
            if let url = URL(string: str) {
                self.process(url: url)
            }
        }
        scanner.show(from: self)
    }
    
    func process(url: URL) {
        let sessionId = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""


        let appKey = "IT7VrTQ0r4InzsvCNJpRCRpi1qzfgpaj" // Get this value from the Keyri Developer Portal
        print("\n In callback \n")
        

        let keyri = Keyri() // Be sure to import the SDK at the top of the file
        keyri.initializeQrSession(username: "testuser@example.com", sessionId: sessionId, appKey: appKey) { res in
            switch res {
            case .success(var session):
                // You can optionally create a custom screen and pass the session ID there. We recommend this approach for large enterprises
                session.payload = "TestPayload"

                // In a real world example you’d wait for user confirmation first
                do {
                    print("confirming session")
                    try session.confirm() // or session.deny()
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
            
        }

        
        
    }
    
}
