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
    
    var pickerData = [["IT7VrTQ0r4InzsvCNJpRCRpi1qzfgpaj", "GZuwAB3QQQ5eTD4st5KmDPDD9PO0xak2", "ZTj8bC8XUUDNEtNw0FBLR6KYbhi7JO9S", "1F3FAZaZ9pcH9DNxyUGoTfi5IF9iqhh6"]]
    var selectedAppKey = "IT7VrTQ0r4InzsvCNJpRCRpi1qzfgpaj"
    
    
    @IBAction func auth(_ sender: Any) {
        let keyri = Keyri()
        keyri.easyKeyriAuth(publicUserId: username.text ?? "", appKey: selectedAppKey, payload: message.text ?? "no message") { bool in
            print(bool)
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
