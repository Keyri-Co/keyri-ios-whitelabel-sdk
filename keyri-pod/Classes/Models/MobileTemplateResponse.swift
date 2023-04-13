//
//  MobileTemplateResponse.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 9/16/22.
//

import Foundation
public class MobileTemplateResponse: NSObject, Codable {
    @objc public var mobile: Mobile
    @objc public var widget: Widget
    @objc public var userAgent: UserAgent
    
    @objc public var title: String
    @objc public var message: String?
}

public class Mobile: NSObject, Codable {
    @objc public var location: String
    @objc public var issue: String?
}

public class Widget: NSObject, Codable {
    @objc public var location: String
    @objc public var issue: String?
}

public class UserAgent: NSObject, Codable {
    @objc public var name: String
    @objc public var issue: String?
}
