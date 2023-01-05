//
//  EPDUtil.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 10/4/22.
//

import Foundation
public class EPDUtil {
    public static func isEPD() -> Bool {
        if files() || write() { return true }
        return false
    }
    
    private static func files() -> Bool {
        if access("/Applications/Cydia.app", F_OK) != -1 || access("/Applications/blackra1n.app", F_OK) != -1 || access("/Applications/FakeCarrier.app", F_OK) != -1 || access("/Applications/Icy.app", F_OK) != -1 || access("/Applications/IntelliScreen.app", F_OK) != -1 || access("/Applications/MxTube.app", F_OK) != -1 || access("/Applications/RockApp.app", F_OK) != -1 || access("/Applications/SBSettings.app", F_OK) != -1 || access("/Applications/WinterBoard.app", F_OK) != -1 || access("/Library/MobileSubstrate/MobileSubstrate.dylib", F_OK) != -1 || access("/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist", F_OK) != -1 || access("/Library/MobileSubstrate/DynamicLibraries/Veency.plist", F_OK) != -1 || access("/private/var/lib/apt", F_OK) != -1 || access("/private/var/lib/cydia", F_OK) != -1 || access("/private/var/mobile/Library/SBSettings/Themes", F_OK) != -1 || access("/private/var/stash", F_OK) != -1 || access("/private/var/tmp/cydia.log", F_OK) != -1 || access("/System/Library/LaunchDaemons/com.ikey.bbot.plist", F_OK) != -1 || access("/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist", F_OK) != -1 || access("/usr/bin/sshd", F_OK) != -1 || access("/usr/libexec/sftp-server", F_OK) != -1 || access("/usr/sbin/sshd", F_OK) != -1 || access("/bin/bash", F_OK) != -1 || access("/etc/apt", F_OK) != -1 {
            return true
        }
        return false
    }
    
    private static func write() -> Bool {
        let error: Error? = nil
        let stringToBeWritten = "helloWorld"
        do {
            try stringToBeWritten.write(toFile: "/private/test1.txt", atomically: true, encoding: .utf8)
        } catch {
        }
        if error == nil {
            return true
        } else {
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: "/private/test1.txt")
            } catch {
            }
        }
        return false

    }
    
    private static func access() -> Bool {
        if let file = fopen("private/var/lib/apt", "r") {
            return true
        }
        
        if let file = fopen("/private/var/stash", "r") {
            return true
        }
    }
}
