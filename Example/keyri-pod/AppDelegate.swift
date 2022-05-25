//
//  AppDelegate.swift
//  keyri-pod
//
//  Created by anovoselskyi on 10/05/2021.
//  Copyright (c) 2021 anovoselskyi. All rights reserved.
//

import UIKit
import keyri_pod
import CryptoKit
import Security
import LocalAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        Keyri.initialize(
//            appkey: "dev_raB7SFWt27VoKqkPhaUrmWAsCJIO8Moj",
//            rpPublicKey: "BOenio0DXyG31mAgUCwhdslelckmxzM7nNOyWAjkuo7skr1FhP7m2L8PaSRgIEH5ja9p+CwEIIKGqR4Hx5Ezam4=",
//            callbackUrl: URL(string: "http://18.208.184.185:5000/users/session-mobile")!
//        )
//        return true
        let keyri = KeyriRegistration()
        keyri.registerOrLogin(for: "", sessionId: "", appKey: "") { result in
            switch result {
                
            case .success(let data):
                print("LFGGGGGG")
                print(data)
            case .failure(_):
                print("sad")
            }
        }
        
        if #available(iOS 13.0, *) {
            let authContext = LAContext();
                

            do {
                let privateKey = try SecureEnclave.P256.KeyAgreement.PrivateKey(
                  authenticationContext: authContext)
                
                print(privateKey.dataRepresentation)
                let derivedPrivateKey = try SecureEnclave.P256.KeyAgreement.PrivateKey(dataRepresentation: privateKey.dataRepresentation)
                
                let derivedPublicKey = derivedPrivateKey.publicKey
                print("PUBLIC KEY")
                print(derivedPublicKey.rawRepresentation)
            } catch {
                print(error)
            }
            
            
        } else {
            
        }
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL
        else {
            return false
        }
                
        return true
    }
}

