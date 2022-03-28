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

    var keyri: Keyri?

    @IBOutlet weak var customTextField: UITextField!
    
    @IBAction func whitelabelAuthAction(_ sender: Any) {
        keyri = Keyri()
        keyri?.whitelabelAuth(custom: customTextField.text ?? "") { [weak self] (result: Result<Void, Error>) in
            self?.keyri = nil
            switch result {
            case .success():
                print()
            case .failure(let error):
                Toast(text: error.localizedDescription, duration: Delay.long).show()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
