//
//  Scanner.swift
//  keyri-pod
//
//  Created by Andrii Novoselskyi on 06.10.2021.
//

import Foundation
import QRCodeReader
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
    
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            
            $0.showTorchButton        = true
            $0.showSwitchCameraButton = true
            $0.showCancelButton       = true
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
                
        return QRCodeReaderViewController(builder: builder)
    }()
    
    init() {
        readerVC.delegate = self
        readerVC.modalPresentationStyle = .formSheet
        
        setupPoweredLabel()
    }
        
    func show(from viewController: UIViewController? = nil) {
        targetViewController = viewController
        presentationController?.present(readerVC, animated: true, completion: nil)
    }
}

extension Scanner {
    private func setupPoweredLabel() {
        let label = UILabel()
        label.text = "Powered by Keyri"
        label.sizeToFit()
        readerVC.view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.bottomAnchor.constraint(equalTo: readerVC.view.bottomAnchor, constant: -50).isActive = true
        label.centerXAnchor.constraint(equalTo: readerVC.view.centerXAnchor).isActive = true
    }
}

extension Scanner: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        completion?(result.value)
        presentationController?.dismiss(animated: true, completion: nil)
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        presentationController?.dismiss(animated: true, completion: nil)
    }
}
