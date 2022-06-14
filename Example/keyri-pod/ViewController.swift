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
    @IBAction func auth(_ sender: Any) {
        let scanner = keyri_pod.Scanner()
        scanner.completion = { str in
            print(str)
        }
        scanner.show(from: self)
    }
    
}
