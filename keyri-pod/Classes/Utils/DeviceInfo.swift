import SwiftUI
import Foundation
import WebKit
import UIKit
import SystemConfiguration.CaptiveNetwork
import CoreTelephony
import AVFoundation
import CryptoKit
import Security

class deviceInfo {
    func getDeviceInfo() -> [String: Any]? {
        let usrSvc = UserService()
        var key = try? usrSvc.verifyExistingUser(username: "ANON")
        if key == nil {
            print("SavingAnonKey")
            key = try? usrSvc.saveKey(for: "ANON")
        }
        
        
        guard let associationKey = key else { return nil }
        
        let device = UIDevice.current
        let screenSize = UIScreen.main.bounds.size
        let screenResolution = "\(Int(screenSize.width))x\(Int(screenSize.height))"
        let osVersion = device.systemVersion
        let timeZone = NSTimeZone.local
        var language = ""
        if #available(iOS 16, *) {
            language = Locale.current.language.languageCode?.identifier ?? ""
        }
        
        let useragent = getUserAgent()
        let deviceName = device.name
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let deviceHash = String(SHA256.hash(data: associationKey.rawRepresentation).description.split(separator: " ")[2])
        let deviceType = UIDevice.current.localizedModel
        let networkType = getNetworkType()
        let storageCapacity = FileManagerUility.getFileSize(for: .systemSize)
        let freeStorage = FileManagerUility.getFileSize(for: .systemFreeSize)
        let wifiSSID = getWifiSSID()?.description
        let packageName = Bundle.main.bundleIdentifier ?? ""
        let keyboardLanguage = getKeyboardLanguage()
        let iCloudToken = getiCloudToken()
        let audioSession = AVAudioSession.sharedInstance()
        let audioOutput = audioSession.currentRoute.outputs.first?.portType.rawValue ?? "Unknown"
        let volume = audioSession.outputVolume
        let screenBrightness = UIScreen.main.brightness
        let deviceOrientation = UIDevice.current.orientation
        
        var isDebuggable = false
        #if DEBUG
            isDebuggable = true
        #endif
        
        var appSignature = ""
        
        return [
            "associationKey": associationKey.rawRepresentation.base64EncodedString(),
            "associationKeysPresent": Keyri(appKey: "").listAssociactionKeys()?.count ?? 0,
            "userId": "ANON",
            "processorType": deviceType,
            //"deviceType": deviceType,
            "deviceName": deviceName,
            "deviceId": deviceId,
            "deviceHash": deviceHash,
            "screenResolution": screenResolution,
            "osVersion": osVersion,
            "timeZone": timeZone.description,
            "language": language,
            "platform": "iOS",
            "userAgent": useragent,
            "networkType": networkType,
            "sdkVersion": "2.5.0", // todo dont hardcode
            "maliciousPackages": "", // FIX
            //"carrier": carrier ?? "unknown",
            "storageCapacity": storageCapacity ?? 0,
            "freeStorage": freeStorage ?? 0,
            "wifiSSID": wifiSSID ?? "unknown",
            "packageName": packageName,
            "appInfoVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            "keyboardLanguage": keyboardLanguage ?? "unknown",
            "iCloudToken": iCloudToken ?? "unknown",
            "audioOutput": audioOutput,
            "volume": volume,
            "isEPD": EPDUtil.isEPD(),
            "screenBrightness": screenBrightness,
            "deviceOrientation": deviceOrientation.rawValue,
            "isDebuggable": isDebuggable,
            "appSignature": appSignature
        ]
    }
    
    func getUserAgent() -> String {
        return WKWebView().value(forKey: "userAgent") as? String ?? ""
    }

    func getNetworkType() -> String {
        let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com")
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)
        if flags.contains(.isWWAN) {
            return "cellular"
        } else {
            return "wifi"
        }
    }

    func getWifiSSID() -> String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }
        for interface in interfaces {
            guard let info = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? else {
                continue
            }
            return info[kCNNetworkInfoKeySSID as String] as? String
        }
        return nil
    }

    func getKeyboardLanguage() -> String? {
        return Locale.preferredLanguages.first
    }

    func getiCloudToken() -> String? {
        return FileManager.default.ubiquityIdentityToken?.description
    }
}

struct FileManagerUility {

    static func getFileSize(for key: FileAttributeKey) -> Int64? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)

        guard
            let lastPath = paths.last,
            let attributeDictionary = try? FileManager.default.attributesOfFileSystem(forPath: lastPath) else { return nil }

        if let size = attributeDictionary[key] as? NSNumber {
            return size.int64Value
        } else {
            return nil
        }
    }

    static func convert(_ bytes: Int64, to units: ByteCountFormatter.Units = .useGB) -> String? {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = units
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes)
    }

}
