//
//  WidgetUserAgent.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 5/25/22.
//

import Foundation

public class WidgetUserAgent: NSObject, Codable {
    @objc var os: String
    @objc var browser: String
}
