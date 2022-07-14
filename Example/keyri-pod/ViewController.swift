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
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var message: UITextField!
    
    
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
    
    override func viewDidLoad() {
        self.statusLabel.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func process(url: URL) {
        let sessionId = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""


        let appKey = "IT7VrTQ0r4InzsvCNJpRCRpi1qzfgpaj" // Get this value from the Keyri Developer Portal
        print("\n In callback \n")
        

        let keyri = Keyri() // Be sure to import the SDK at the top of the file
        keyri.initializeQrSession(username: username.text ?? "ANON", sessionId: sessionId, appKey: appKey) { res in
            DispatchQueue.main.async {
                switch res {
                case .success(var session):
                    // You can optionally create a custom screen and pass the session ID there. We recommend this approach for large enterprises
                    session.payload = "\(self.username.text ?? "ANON") says \(self.message.text ?? "nothing")"

                    // In a real world example you’d wait for user confirmation first
                    do {
                        print("confirming session")
                        try session.confirm() // or session.deny()
                        
                            self.showAlert(title: "Success", message: "\(self.username.text) logged in" )
                        
                    } catch {
                        print(error)
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                case .failure(let error):
                    print(error)
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        
        
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        username.resignFirstResponder()
        message.resignFirstResponder()
        
    }
    
}
