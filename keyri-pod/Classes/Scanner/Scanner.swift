//
//  Scanner.swift
//  keyri-pod
//
//  Created by Andrii Novoselskyi on 06.10.2021.
//

import Foundation
import AVFoundation

class Scanner {
    var completion: ((String) -> Void)?
    
    private var targetViewController: UIViewController?
    private var presentationController: UIViewController? {
        if let targetViewController = targetViewController {
            return targetViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController?.topMostViewController()
        }
    }
    
    func show(from viewController: UIViewController? = nil) {
        targetViewController = viewController
        let scanner = QRCodeScannerController(
            cameraImage: UIImage(named: "switch-camera-button", in: Keyri.resourceBundle, compatibleWith: nil),
            cancelImage: nil,
            flashOnImage: UIImage(named: "flash", in: Keyri.resourceBundle, compatibleWith: nil),
            flashOffImage: UIImage(named: "flash-off", in: Keyri.resourceBundle, compatibleWith: nil)
        )
        scanner.delegate = self
        presentationController?.present(scanner, animated: true, completion: nil)
        
        let label = UILabel()
        label.text = "Powered by Keyri"
        label.sizeToFit()
        scanner.view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.bottomAnchor.constraint(equalTo: scanner.view.bottomAnchor, constant: -100).isActive = true
        label.centerXAnchor.constraint(equalTo: scanner.view.centerXAnchor).isActive = true
    }
}

extension Scanner: QRScannerCodeDelegate {
    
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        completion?(result)
        presentationController?.dismiss(animated: true, completion: nil)
    }
    
    func qrScannerDidFail(_ controller: UIViewController, error: String) {
        presentationController?.dismiss(animated: true, completion: nil)
    }
    
    func qrScannerDidCancel(_ controller: UIViewController) {
        presentationController?.dismiss(animated: true, completion: nil)
    }
}
