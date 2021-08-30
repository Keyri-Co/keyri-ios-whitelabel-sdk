//
//  AppDelegate.swift
//  KeyriExample
//
//  Created by Andrii Novoselskyi on 25.08.2021.
//

import UIKit
import Keyri

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
                
        Keyri.shared.initialize(
            id: "60f180ac10cdf71478f462c7",
            name: "Keyri Service Manager",
            callbackUrl: URL(string: "http://18.234.201.114:5000/users/session-mobile")!,
            logoUrl: URL(string: "https://users-images-keyri.s3.amazonaws.com/serviceLogo/logo-c5518e8f40d7b09d8e7d30282ac8c603.png")!
        )
                
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

