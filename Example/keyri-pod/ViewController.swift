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
    
    func showToast(message: String) {
        Toast(text: message, duration: Delay.long).show()
    }
    
    func process(url: URL) {
        let sessionId = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""
        keyri = Keyri()
        keyri?.handleSessionId(sessionId, completion: { [weak self] sessionResult in
            switch sessionResult {
            case .success(let session):
                if session.isNewUser {
                    self?.signup(session: session)
                } else {
                    self?.login(session: session)
                }
            case .failure(let error):
                Toast(text: error.localizedDescription, duration: Delay.long).show()
            }
        })
    }

    @IBAction func scanAction(_ sender: Any) {
        state = .signup
        present(scanner, animated: true, completion: nil)
    }
    
    @IBAction func getAllAccounts(_ sender: Any) {
        keyri = Keyri()
        keyri?.getAccounts() { [weak self] result in
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
    
    @IBAction func removeFirstAccounts(_ sender: Any) {
        keyri = Keyri()
        keyri?.getAccounts() { [weak self] result in
            switch result {
            case .success(let allAccounts):
                guard let accountToRemove = allAccounts.first else {
                    print("No account to remove")
                    return
                }
                print("Account \(accountToRemove.username) will be removed")
                self?.keyri?.removeAccount(account: accountToRemove) { (removeResult: Result<Void, Error>) in
                    self?.keyri = nil
                    switch removeResult {
                    case .success():
                        print("Account \(accountToRemove.username) has been successfully removed")
                    case .failure(let error):
                        print(error)
                        Toast(text: error.localizedDescription, duration: Delay.long).show()
                    }
                }
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
        keyri?.directSignup(username: "tester 1", custom: "custom mobile signup", extendedHeaders: ["TestKey1": "TestVal1", "TestKey2": "TestVal2"]) { [weak self] result in
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
        keyri?.getAccounts() { [weak self] result in
            if case .success(let accounts) = result, let account = accounts.first {
                self?.keyri?.directLogin(account: account, custom: "custom mobile signin", extendedHeaders: ["TestKey1": "TestVal1", "TestKey2": "TestVal2"]) { result in
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
        keyri?.easyKeyriAuth(custom: "custom auth with scanner") { [weak self] (result: Result<Void, Error>) in
            self?.keyri = nil
            switch result {
            case .success():
                print()
            case .failure(let error):
                Toast(text: error.localizedDescription, duration: Delay.long).show()
            }
        }
    }
    
    @IBAction func whitelabelAuth(_ sender: Any) {
        keyri = Keyri()
        keyri?.whitelabelAuth(custom: "some custom") { [weak self] (result: Result<Void, Error>) in
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

extension ViewController {
    private func signup(session: Session) {
        guard let username = session.username else { return }
        keyri?.sessionSignup(username: username, service: session.service, custom: nil, completion: { [weak self] (signupResult: Result<Void, Error>) in
            self?.keyri = nil
            switch signupResult {
            case .success(let response):
                print(response)
                Toast(text: "Signup successfully completed", duration: Delay.long).show()
            case .failure(let error):
                Toast(text: error.localizedDescription, duration: Delay.long).show()
            }
        })
    }
    
    private func login(session: Session) {
        keyri?.getAccounts() { [weak self] result in
            if case .success(let accounts) = result, let account = accounts.first {
                self?.keyri?.sessionLogin(account: account, service: session.service, custom: "test custom login") { (result: Result<Void, Error>) in
                    self?.keyri = nil
                    switch result {
                    case .success(_):
                        print("Login successfully completed")
                        Toast(text: "Login successfully completed", duration: Delay.long).show()
                    case .failure(let error):
                        print("Login failed: \(error.localizedDescription)")
                        Toast(text: error.localizedDescription, duration: Delay.long).show()
                    }
                }
            } else {
                self?.keyri = nil
                print("no accounts found")
                Toast(text: "no accounts found", duration: Delay.long).show()
            }
        }
    }
}

extension ViewController: QRScannerCodeDelegate {
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        let sessionId = URLComponents(string: result)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""
        keyri = Keyri()
        keyri?.handleSessionId(sessionId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let session):
                switch self.state {
                case .signup:
                    self.signup(session: session)
                case .login:
                    self.login(session: session)
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
