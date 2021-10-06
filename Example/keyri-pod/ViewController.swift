//
//  ViewController.swift
//  KeyriExample
//
//  Created by Andrii Novoselskyi on 25.08.2021.
//

import UIKit
import QRCodeReader
import AVFoundation
import keyri_pod

class ViewController: UIViewController {
    
    enum State {
        case idle, login, signup
    }
    
    var state: State = .idle

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            
            // Configure the view controller (optional)
            $0.showTorchButton        = true
            $0.showSwitchCameraButton = true
            $0.showCancelButton       = true
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()

    @IBAction func scanAction(_ sender: Any) {
        state = .signup
        
        readerVC.delegate = self
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    @IBAction func getAllAccounts(_ sender: Any) {
        Keyri.shared.accounts() { result in
            switch result {
            case .success(let allAccounts):
                print(allAccounts)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func login(_ sender: Any) {
        state = .login
        
        readerVC.delegate = self
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    @IBAction func mobileSignUp(_ sender: Any) {
        Keyri.shared.mobileSignUp(username: "tester 1", custom: "custom mobile signup") { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    @IBAction func mobileSignIn(_ sender: Any) {
        Keyri.shared.accounts() { result in
            if case .success(let accounts) = result, let account = accounts.first {
                Keyri.shared.mobileLogin(account: account, custom: "custom mobile signin") { result in
                    switch result {
                    case .success(let response):
                        print(response)
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @IBAction func authWithScanner(_ sender: Any) {
        Keyri.shared.authWithScanner(custom: "custom auth with scanner") { result in
            switch result {
            case .success():
                print()
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

extension ViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        let sessionId = result.value
        Keyri.shared.onReadSessionId(sessionId) { result in
            if case .success(let session) = result {
                switch self.state {
                case .signup:
                    guard let username = session.username else {
                        return
                    }
                    Keyri.shared.signUp(username: username, service: session.service, custom: "test custom signup") { result in
                        switch result {
                        case .success(_):
                            print("Signup successfully completed")
                        case .failure(let error):
                            print("Signup failed: \(error.localizedDescription)")
                        }
                    }
                case .login:
                    Keyri.shared.accounts() { result in
                        if case .success(let accounts) = result, let account = accounts.first {
                            Keyri.shared.login(account: account, service: session.service, custom: "test custom login") { result in
                                switch result {
                                case .success(_):
                                    print("Login successfully completed")
                                case .failure(let error):
                                    print("Login failed: \(error.localizedDescription)")
                                }
                            }
                        } else {
                            print("no accounts found")
                        }
                    }
                default:
                    break
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
}
