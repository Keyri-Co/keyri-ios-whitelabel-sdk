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
    @IBOutlet weak var appKeySelector: UIPickerView!
    
    var pickerData = [["IT7VrTQ0r4InzsvCNJpRCRpi1qzfgpaj", "GZuwAB3QQQ5eTD4st5KmDPDD9PO0xak2", "ZTj8bC8XUUDNEtNw0FBLR6KYbhi7JO9S", "1F3FAZaZ9pcH9DNxyUGoTfi5IF9iqhh6", "113ce3c2-5ed7-11ed-9b6a-0242ac120002", "22d37851-f1b6-4f4b-8229-0c791eb05f2a"]]
    var selectedAppKey = "IT7VrTQ0r4InzsvCNJpRCRpi1qzfgpaj"
    
    @IBAction func auth(_ sender: Any) {
        let keyri = Keyri()
        keyri.easyKeyriAuth(publicUserId: username.text ?? "", appKey: selectedAppKey, payload: message.text ?? "no message") { bool in
            print(bool)
        }
        
//        let scanner = Scanner()
//        scanner.completion = { str in
//            guard let url = URL(string: str) else { return }
//            self.process(url: url)
//        }
//        scanner.show()
    }

    func process(url: URL) {
        let sessionId = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""
        let payload = "Custom payload here"
        let appKey = selectedAppKey // Get this value from the Keyri Developer Portal

        let keyri = Keyri() // Be sure to import the SDK at the top of the file
        let res = keyri.initiateQrSession(username: "lol", sessionId: sessionId, appKey: appKey) { result in
            switch result {
            case .success(let session):
                DispatchQueue.main.async {
                    keyri.initializeDefaultConfirmationScreen(session: session, payload: payload) { bool in
                        print(bool)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }


            
        
    }
    
    override func viewDidLoad() {
        self.statusLabel.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        self.appKeySelector.delegate = self
        self.appKeySelector.dataSource = self
        
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

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedAppKey = pickerData[component][row]
        print("CHANGING APPKEY \n")
        print(self.selectedAppKey)
    }
    
    
    
    
    
}
