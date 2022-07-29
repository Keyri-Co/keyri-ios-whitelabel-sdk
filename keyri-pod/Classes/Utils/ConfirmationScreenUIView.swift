//
//  ConfirmationScreenObjC.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 7/25/22.
//

import Foundation
import SwiftUI

@objcMembers open class ConfirmationScreenUIView: NSObject {
    public var vc: UIHostingController<ConfirmationScreen>
    
    @objc public init(session: Session, dismissalDelegate: @escaping (Bool) -> ()) {
        var CS = ConfirmationScreen(session: session)
        CS.dismissalAction = dismissalDelegate
        vc = UIHostingController(rootView: CS)
    }
    
    public var view: UIView {
        return vc.view
    }
    
    
    
    
}
