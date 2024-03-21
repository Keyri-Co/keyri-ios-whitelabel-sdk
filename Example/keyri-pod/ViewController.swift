//
//  ViewController.swift
//  KeyriExample
//
//  Created by Andrii Novoselskyi on 25.08.2021.
//

import UIKit
import AVFoundation
import Keyri

class ViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var appKeySelector: UIPickerView!

    @IBAction func auth(_ sender: Any) {
        let keyri = KeyriInterface(appKey: selectedAppKey)

        keyri.easyKeyriAuth(payload: message.text ?? "no message", publicUserId: username.text ?? "") { bool in
            print(bool)
        }
    }

    func process(url: URL) {
        let sessionId = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""
        let payload = "Custom payload here"

        let keyri = KeyriInterface(appKey: selectedAppKey) // Be sure to import the SDK at the top of the file

        keyri.initiateQrSession(sessionId: sessionId, publicUserId: "lol") { result in
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
