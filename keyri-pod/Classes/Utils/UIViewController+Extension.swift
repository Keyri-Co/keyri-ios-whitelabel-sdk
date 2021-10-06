//
//  UIViewController+Extension.swift
//  keyri-pod
//
//  Created by Andrii Novoselskyi on 06.10.2021.
//

import Foundation

extension UIViewController {    
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
}
