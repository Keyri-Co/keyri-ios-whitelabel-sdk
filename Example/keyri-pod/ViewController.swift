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
    
    enum State {
        case idle, login, signup
    }
    
    var state: State = .idle

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

    @IBAction func scanAction(_ sender: Any) {
        state = .signup
        present(scanner, animated: true, completion: nil)
    }
    
    @IBAction func getAllAccounts(_ sender: Any) {
        keyri = Keyri()
        keyri?.accounts() { [weak self] result in
            self?.keyri = nil
            switch result {
            case .success(let allAccounts):
                print(allAccounts.map { $0.username })
            case .failure(let error):
                print(error)
                Toast(text: error.localizedDescription, duration: Delay.long).show()
            }
        }
    }
    
    @IBAction func login(_ sender: Any) {
        state = .login
        present(scanner, animated: true, completion: nil)
    }
    
    @IBAction func mobileSignUp(_ sender: Any) {
        keyri = Keyri()
        keyri?.mobileSignup(username: "tester 1", custom: "custom mobile signup", extendedHeaders: ["TestKey1": "TestVal1", "TestKey2": "TestVal2"]) { [weak self] result in
            self?.keyri = nil
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                Toast(text: error.localizedDescription, duration: Delay.long).show()
            }
        }
    }
    
    @IBAction func mobileSignIn(_ sender: Any) {
        keyri = Keyri()
        keyri?.accounts() { [weak self] result in
            if case .success(let accounts) = result, let account = accounts.first {
                self?.keyri?.mobileLogin(account: account, custom: "custom mobile signin", extendedHeaders: ["TestKey1": "TestVal1", "TestKey2": "TestVal2"]) { result in
                    self?.keyri = nil
                    switch result {
                    case .success(let response):
                        print(response)
                    case .failure(let error):
                        Toast(text: error.localizedDescription, duration: Delay.long).show()
                    }
                }
            } else {
                self?.keyri = nil
            }
        }
    }
    
    @IBAction func authWithScanner(_ sender: Any) {
        keyri = Keyri()
        keyri?.authWithScanner(custom: "custom auth with scanner") { [weak self] (result: Result<Void, Error>) in
            self?.keyri = nil
            switch result {
            case .success():
                print()
            case .failure(let error):
                Toast(text: error.localizedDescription, duration: Delay.long).show()
            }
        }
    }
}

extension ViewController: QRScannerCodeDelegate {
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        keyri = Keyri()
        keyri?.onReadSessionId(result) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let session):
                switch self.state {
                case .signup:
                    guard let username = session.username else {
                        self.keyri = nil
                        return
                    }
                    self.keyri?.signup(username: username, service: session.service, custom: "test custom signup") { (result: Result<Void, Error>) in
                        self.keyri = nil
                        switch result {
                        case .success(_):
                            print("Signup successfully completed")
                        case .failure(let error):
                            print("Signup failed: \(error.localizedDescription)")
                            Toast(text: error.localizedDescription, duration: Delay.long).show()
                        }
                    }
                case .login:
                    self.keyri?.accounts() { result in
                        if case .success(let accounts) = result, let account = accounts.first {
                            self.keyri?.login(account: account, service: session.service, custom: "test custom login") { (result: Result<Void, Error>) in
                                self.keyri = nil
                                switch result {
                                case .success(_):
                                    print("Login successfully completed")
                                case .failure(let error):
                                    print("Login failed: \(error.localizedDescription)")
                                    Toast(text: error.localizedDescription, duration: Delay.long).show()
                                }
                            }
                        } else {
                            self.keyri = nil
                            print("no accounts found")
                            Toast(text: "no accounts found", duration: Delay.long).show()
                        }
                    }
                default:
                    break
                }
            case .failure(let error):
                self.keyri = nil
                Toast(text: error.localizedDescription, duration: Delay.long).show()
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func qrScannerDidFail(_ controller: UIViewController, error: String) {
        dismiss(animated: true, completion: nil)
    }
    
    func qrScannerDidCancel(_ controller: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
}
