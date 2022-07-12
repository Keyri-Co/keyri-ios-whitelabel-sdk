//
//  Scanner.swift
//  keyri-pod
//
//  Created by Andrii Novoselskyi on 06.10.2021.
//

import Foundation
import AVFoundation

open class Scanner {
    public var completion: ((String) -> Void)?
    
    public init() {}
    
    private var targetViewController: UIViewController?
    private var presentationController: UIViewController? {
        if let targetViewController = targetViewController {
            return targetViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController?.topMostViewController()
        }
    }
    
    public func show(from viewController: UIViewController? = nil) {
        targetViewController = viewController
        let scanner = QRCodeScannerController(
            cameraImage: UIImage(named: "switch-camera-button"),
            cancelImage: nil,
            flashOnImage: UIImage(named: "flash"),
            flashOffImage: UIImage(named: "flash-off")
        )
        scanner.delegate = self
        presentationController?.present(scanner, animated: true, completion: nil)
        
        let label = UILabel()
        label.text = "Powered by Keyri"
        label.textColor = UIColor.systemGray
        label.sizeToFit()
        scanner.view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.bottomAnchor.constraint(equalTo: scanner.view.bottomAnchor, constant: -100).isActive = true
        label.centerXAnchor.constraint(equalTo: scanner.view.centerXAnchor).isActive = true
    }
}

extension Scanner: QRCodeScannerDelegate {
    
    public func qrCodeScanner(_ controller: UIViewController, scanDidComplete result: String) {
        print(completion)
        completion?(result)
        presentationController?.dismiss(animated: true, completion: nil)
    }
    
    public func qrCodeScannerDidFail(_ controller: UIViewController, error: String) {
        presentationController?.dismiss(animated: true, completion: nil)
    }
    
    public func qrCodeScannerDidCancel(_ controller: UIViewController) {
        presentationController?.dismiss(animated: true, completion: nil)
    }
}
