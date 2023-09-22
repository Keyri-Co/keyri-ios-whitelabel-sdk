<p align="center">
    <a href="">
        <img src="https://keyri.com/wp-content/uploads/2022/09/Keyri-Grey-Logo-Website-300x147.png" width=200 />
    </a>
</p>

<p align="center">Keyri QR login iOS SDK written in Swift</p>

# Overview

This repository contains the open-source code for [Keyri](https://keyri.com) iOS SDK.

[![GitHub release](https://img.shields.io/github/release/Keyri-Co/keyri-ios-whitelabel-sdk.svg?maxAge=10)](https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk/releases)

The latest source code of the Keyri iOS SDK can be found
here: [Releases](https://github.com/Keyri-Co/keyri-ios-whitelabel-sdk/releases)

## Contents

* [System Requirements](#system-requirements)
* [Integration](#integration)
* [QR Login - Universal Links](#qr-login---universal-links)
* [QR Login - In-App Scanner](#qr-login---in-app-scanner)
* [Device Fingerprinting](#device-fingerprinting)
* [Interacting with the API](#interacting-with-the-api)
* [Session Object](#session-object)
* [Disclaimer](#Disclaimer)
* [License](#license)

### **System Requirements**

* iOS 14+
* Swift 5+
* Apple A7 chip or newer (The A7 shipped with the iPhone 5s)

### **Table of Contents**

* Integration
* QR Login
* Device Fingerprinting
* Interacting with the API
* Session Object

### **Integration**

****[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. For usage and installation
instructions, visit their website. To integrate Keyri iOS SDK into your Xcode project using CocoaPods, specify it in
your Podfile:

```ruby
pod 'keyri-pod'
```

The SDK can then be imported into any Swift file as follows

```swift
import keyri-pod
```

### **QR Login - Universal Links**

To handle Universal Links (e.g., for QR login straight from the user's built-in camera app), you need to add the
Associated Domains Entitlement to your App.entitlements. To set up the entitlement in your app, open the target’s
Signing & Capabilities tab in Xcode and add the Associated Domains capability, or if you already have entitlements you
can modify your App.entitlements file to match this example:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>com.apple.developer.associated-domains</key>
        <array>
            <string>applinks:{domainName}</string>
        </array>
    </dict>
</plist>
```

This will handle all links with the following scheme: `https://{yourCompany}.onekey.to?sessionId={sessionId}`

**Note:** Keyri will create your `https://{yourCompany}.onekey.to` page automatically once you configure it in
the [dashboard](https://app.keyri.com)

In the AppDelegate where the processing of links is declared, you need to add handlers in
the `application(_:continue:restorationHandler:)` method:

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
        let incomingURL = userActivity.webpageURL
    else {
        return false
    }
    
    process(url: incomingURL)
    
    return true
}

func process(url: URL) {
    let sessionId = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""
    let payload = "Custom payload here"
    let appKey = selectedAppKey // Get this value from the Keyri Developer Portal
    let publicApiKey = nil // Get this optional value from the Keyri Developer Portal
    let serviceEncryptionKey = nil // Get this optional value from the Keyri Developer Portal

    let keyri = KeyriInterface(appKey, publicApiKey, serviceEncryptionKey) // Be sure to import the SDK at the top of the file
    
    let res = keyri.initializeQrSession(sessionId: sessionId, publicUserId: publicUserId) { result in
        switch result {
            case .success(let session):
                DispatchQueue.main.async {
                    keyri.initializeDefaultScreen(session: session, payload: payload) { boolResult in
                        print(boolResult)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
        }
    }
}
```

**Note:** Keyri will set up the required `/.well-known/apple-app-site-association` JSON at
your `https://{yourSubdomain}.onekey.to` page as required by Apple to handle Universal Link handling. Details on this
mechanism are described here: <https://developer.apple.com/documentation/Xcode/supporting-associated-domains>

### **QR Login - In-App Scanner**

This can be used in conjunction with Universal links or exclusively.

The Keyri SDK includes a default Scanner view, which can be invoked and displayed as shown below. Unfortunately, due to
platform limitations, we had to keep this in UIKit for the time being, but will be on the lookout for options to convert
over to SwiftUI as time goes on. The completion block is the important piece here: we return the exact string as shown
in the QR code. All you need to do is convert to URL, and then you're free to process the response the same way we did
above (notice the `process(url)` function is exactly the same in both cases)

```swift
ptfunc handleDisplayingScanner() {
    let scanner = Scanner()
    scanner.completion = { str in 
        guard let url = URL(string: str) else { return nil }
        process(url)
    }

    scanner.show()
}

func process(url: URL) {
    let sessionId = URLComponents(url: url, resolvingAgainstBaseURL: true)?
    .queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""
    let payload = "Custom payload here"
    let appKey = selectedAppKey // Get this value from the Keyri Developer Portal
    let publicApiKey = nil // Get this optional value from the Keyri Developer Portal
    let serviceEncryptionKey = nil // Get this optional value from the Keyri Developer Portal

    let keyri = KeyriInterface(appKey, publicApiKey, serviceEncryptionKey) // Be sure to import the SDK at the top of the file
    let res = keyri.initializeQrSession(sessionId: sessionId, publicUserId: publicUserId)

    switch res {
    case .success(let session):
        // You can optionally create a custom screen and pass the session there. We recommend this approach for large enterprises
        initializeDefaultScreen(session: session, payload: payload)

        // In a real world example you’d wait for user confirmation first
        session.confirm(payload: payload, trustNewBrowser: true) // or session.deny(payload: payload)
    case .failure(let error):
        print(error)
    }
}
```

### **Device Fingerprinting**

Keyri Enables mobile device fingerprinting that persists even when the application is deleted and reinstalled. Below is
a simple example of how this can be leveraged, in this case limiting to 1 user per device

```swift
func registerUser(publicUserId: String) throws {
    let keyri = KeyriInterface(appKey, publicApiKey, serviceEncryptionKey)

	  if let list = keyri.listUniqueAccounts() {
		  if let existingUsername = list.keys.first {
		    // Alert user that there is an existing user, and encourage them to sign in here
		  }
	  } else {
		let key = try keyri.generateAssociationKey(publicUserId: publicUserId)
		// Then run your regular registration process
		// Optionally, do something else with the key that was just generated
		// Keyri handles saving the key in the Secure Enclave for you
		// For example, you can later use this key pair to passwordlessly authenticate the user
	}
}
```

### **Interacting with the API**

The following methods are available to interact with the Keyri SDK API, which can be used to craft your own custom flows
and leverage the SDK in different ways:

* `func initiateQrSession(sessionId: String, publicUserId: String?, completion: @escaping (Result<Session, Error>) -> Void)` -
  call after obtaining the sessionId from QR-code or deep link. Returns Session object with Risk attributes (needed to
  show confirmation screen) or Exception.

* `func initializeDefaultConfirmationScreen(session: Session, payload: String, completion: @escaping (Bool) -> ())` - to
  show Confirmation with default UI. Alternatively, you can implement a custom Confirmation Screen. The Default screen
  is built using SwiftUI, however the session object is designed to work seamlessly with UIKit as well should you prefer
  that route.

* `func Session.confirm(completion: @escaping (Error?) -> ())` - call this function if user
  confirms the dialog. Returns authentication callback result or error.

* `func Session.deny(completion: @escaping (Error?) -> ())` - call if the user denys the dialog.
  Returns authentication callback result or error.

* `func generateAssociationKey(publicUserId: String = "ANON", completion: @escaping (Result<P256.Signing.PublicKey, Error>))` - creates a persistent ECDSA keypair for the given public
  user ID (example: email address) and return public key.

* `func generateUserSignature(publicUserId: String = "ANON", data: Data, completion: @escaping (Result<P256.Signing.ECDSASignature, Error>) -> ())` - returns an ECDSA signature of the
  timestamp and optional customSignedData with the publicUserId's privateKey (or, if not provided, anonymous
  privateKey), customSignedData can be anything.

* `func getAssociationKey(publicUserId: String = Constants.ANON_USER, completion: @escaping (Result<P256.Signing.PublicKey?, Error>) -> ())` - returns Base64 public key for the specified publicUserId.

* `func removeAssociationKey(publicUserId: String, completion: @escaping (Result<Void, Error>) -> ())` - removes key for given user, deleting their record.

* `func listAssociationKeys(completion: @escaping (Result<[String:String]?, Error>) -> ())` - returns a map of username to association key, every such key on the
  device.

* `func listUniqueAccounts(completion: @escaping (Result<[String:String]?, Error>) -> ())` - returns a map of username to association key, every such key on the
device, but without the anonymous account as is returned above.

* `payload` can be anything (session token or a stringified JSON containing multiple items. Can include things like
publicUserId, timestamp, customSignedData and ECDSA signature).

### **Session Object**

The session object is returned on successful initializeQrSession calls, and is used to handle presenting the situation to
the end user and getting their confirmation to complete authentication. Below are some of the key properties and methods
that can be triggered. If you are utilizing the built-in views, you are only responsible for calling the confirm/deny
methods above

* IPAddressMobile/Widget - the IP Address of both mobile device and web browser&#x20;

* WidgetUserAgent - the browser user-agent (e.g., Chrome on macOS)&#x20;

* RiskAnalytics - if available on your subscription plan

    * RiskStatus - clear, warn or deny

    * RiskFlagString - if RiskStatus is warn or deny, this string alerts the user to what is triggering the risk
      situation

    * GeoData - Location data for both mobile and widget

        * Mobile

            * city

            * country\_code

        * Browser

            * city

            * country\_code

* Session.confirm() and Session.deny() - see descriptions in **Interacting with the API**

### Disclaimer

We care deeply about the quality of our product and rigorously test every piece of functionality we
offer. That said, every integration is different. Every app on the App Store has a different
permutation of build settings, compiler flags, processor requirements, compatibility issues etc and
it's impossible for us to cover all of those bases, so we strongly recommend thorough testing of
your integration before shipping to production. Please feel free to file a bug or issue if you
notice anything that seems wrong or strange on GitHub 🙂

[Issues](https://github.com/Keyri-Co/keyri-android-whitelabel-sdk/issues)

This library is available under paid and free licenses. See the [LICENSE](LICENSE) file for the
full license text.

* Details of licensing (pricing, etc) are available
  at [https://keyri.com/pricing](https://keyri.com/pricing), or you can contact us
  at [Sales@keyri.com](mailto:Sales@keyri.com).

### Details

What's allowed under the license:

* Free use for any app under the Keyri Developer plan.
* Any modifications as needed to work in your app

What's not allowed under the license:

* Redistribution under a different license
* Removing attribution
* Modifying logos
* Indemnification: using this free software is ‘at your own risk’, so you can’t sue Keyri, Inc. for
  problems caused by this library
