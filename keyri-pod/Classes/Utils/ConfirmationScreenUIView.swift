//
//  ConfirmationScreenObjC.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 7/25/22.
//

import Foundation
import SwiftUI

@objcMembers class ConfirmationScreenUIView: NSObject {
    var vc: UIHostingController<ConfirmationScreen>
    
    @objc public init(session: Session, dismissalDelegate: @escaping (String) -> ()) {
        var CS = ConfirmationScreen(session: session)
        CS.dismissalAction = dismissalDelegate
        vc = UIHostingController(rootView: CS)
    }
    
    public var view: UIView {
        return vc.view
    }
    
    
    
    
}
