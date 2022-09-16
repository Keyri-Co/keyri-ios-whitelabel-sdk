//
//  MobileTemplateResponse.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 9/16/22.
//

import Foundation
public class MobileTemplateResponse: NSObject, Codable {
    @objc var mobile: Mobile
    @objc var widget: Widget
    @objc var userAgent: UserAgent
    
    @objc var title: String
    @objc var message: String?
}

public class Mobile: NSObject, Codable {
    @objc var location: String
    @objc var issue: String?
}

public class Widget: NSObject, Codable {
    @objc var location: String
    @objc var issue: String?
}

public class UserAgent: NSObject, Codable {
    @objc var name: String
    @objc var issue: String?
}
