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
        
        process(url: incomingURL)
        
        return true
    }

    func process(url: URL) {
        let sessionId = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""
        let payload = "Custom payload here"
        let appKey = "App key here" // Get this value from the Keyri Developer Portal

        let keyri = Keyri() // Be sure to import the SDK at the top of the file
        keyri.initiateQrSession(username: "TestUser", sessionId: sessionId, appKey: appKey) { res in
            switch res {
            case .success(let session):
                // You can optionally create a custom screen and pass the session ID there. We recommend this approach for large enterprises
                session.payload = payload

                // In a real world example you’d wait for user confirmation first

                _ = session.confirm() // or session.deny()

            case .failure(let error):
                print(error)
            }
            
        }
    }
}
