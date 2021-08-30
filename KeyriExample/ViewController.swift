//
//  ViewController.swift
//  KeyriExample
//
//  Created by Andrii Novoselskyi on 25.08.2021.
//

import UIKit
import QRCodeReader
import AVFoundation
import Keyri

class ViewController: UIViewController {
    
    enum State {
        case idle, login, signup
    }
    
    var state: State = .idle

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            
            // Configure the view controller (optional)
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = false
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()

    @IBAction func scanAction(_ sender: Any) {
        state = .signup
        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self

        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
          print(result)
        }

        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
       
        present(readerVC, animated: true, completion: nil)
    }
    
    @IBAction func getAllAccounts(_ sender: Any) {
        let allAccounts = Keyri.shared.accounts()
        print(allAccounts)
    }
    
    @IBAction func login(_ sender: Any) {
        state = .login

//        guard let account = Keyri.shared.accounts().first else {
//            print("no accounts found")
//            return
//        }
//
//        Keyri.shared.login(sessionId: <#T##String#>, service: <#T##Service#>, account: <#T##PublicAccount#>, custom: <#T##String?#>)
        
        readerVC.delegate = self

        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
          print(result)
        }

        // Presents the readerVC as modal form sheet
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
        guard let account = Keyri.shared.accounts().first else { return }
        Keyri.shared.mobileLogin(account: account, custom: "custom mobile signin") { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
                    Keyri.shared.signUp(username: username, sessionId: sessionId, service: session.service, custom: "test custom signup")
                case .login:
                    guard let account = Keyri.shared.accounts().first else {
                        print("no accounts found")
                        return
                    }
                    Keyri.shared.login(sessionId: sessionId, service: session.service, account: account, custom: "test custom login")
                default:
                    break
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }

    //This is an optional delegate method, that allows you to be notified when the user switches the cameraName
    //By pressing on the switch camera button
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        let cameraName = newCaptureDevice.device.localizedName
        print("Switching capture to: \(cameraName)")

    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
      reader.stopScanning()

      dismiss(animated: true, completion: nil)
    }
}
