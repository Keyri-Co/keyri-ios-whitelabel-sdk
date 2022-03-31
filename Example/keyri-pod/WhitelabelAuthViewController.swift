//
//  WhitelabelAuthViewController.swift
//  keyri-pod_Example
//
//  Created by Andrii Novoselskyi on 28.03.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import keyri_pod
import Toaster

class WhitelabelAuthViewController: UIViewController {

    var scanner: QRCodeScannerController {
        let scanner = QRCodeScannerController(
            cameraImage: UIImage(named: "switch-camera-button"),
            cancelImage: nil,
            flashOnImage: UIImage(named: "flash"),
            flashOffImage: UIImage(named: "flash-off")
        )
        scanner.delegate = self
        
        let label = UILabel()
        label.text = "Powered by Keyri"
        label.sizeToFit()
        scanner.view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.bottomAnchor.constraint(equalTo: scanner.view.bottomAnchor, constant: -100).isActive = true
        label.centerXAnchor.constraint(equalTo: scanner.view.centerXAnchor).isActive = true
        
        return scanner
    }

    var keyri: Keyri?

    @IBOutlet weak var customTextField: UITextField!
    
    @IBAction func whitelabelAuthAction(_ sender: Any) {
        guard let custom = customTextField.text, !custom.isEmpty else {
            Toast(text: "Custom should not be empty", duration: Delay.long).show()
            return
        }
        present(scanner, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension WhitelabelAuthViewController: QRScannerCodeDelegate {
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        let sessionId = URLComponents(string: result)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""
        keyri = Keyri()
        keyri?.whitelabelAuth(sessionId: sessionId, custom: customTextField.text ?? "", completion: { [weak self] (result: Result<Void, Error>) in
            self?.keyri = nil
            switch result {
            case .success():
                print()
            case .failure(let error):
                Toast(text: error.localizedDescription, duration: Delay.long).show()
            }
        })
        dismiss(animated: true, completion: nil)
    }
    
    func qrScannerDidFail(_ controller: UIViewController, error: String) {
        dismiss(animated: true, completion: nil)
    }
    
    func qrScannerDidCancel(_ controller: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
}
