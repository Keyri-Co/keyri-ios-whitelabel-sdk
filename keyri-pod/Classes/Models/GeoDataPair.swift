//
//  GeoData.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 5/25/22.
//

import Foundation

public class GeoDataPair: NSObject, Codable {
    @objc var mobile: LocationData?
    @objc var browser: LocationData?
}
