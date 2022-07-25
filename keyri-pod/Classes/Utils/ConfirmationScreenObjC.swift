//
//  ConfirmationScreenObjC.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 7/25/22.
//

import Foundation
import SwiftUI

@objcMembers class ConfirmationScreenObjC: NSObject {
    var vc: UIHostingController<ConfirmationScreen>
    
    @objc public init(session: Session) {
        vc = UIHostingController(rootView: ConfirmationScreen(session: session))
    }
    
    public var view: UIView {
        return vc.view
    }
    
    
}
