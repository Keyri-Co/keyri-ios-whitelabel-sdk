import CryptoKit

open class Keyri {
    
    var activeSession: Session?
    
    public init() {}
    
    public func initiateQrSession(username: String?, sessionId: String, appKey: String, completionHandler: @escaping (Result<Session, Error>) -> Void) {
        let usrSvc = UserService()
        let usr = username ?? "ANON"
        
        do {
            var key = try usrSvc.verifyExistingUser(username: usr)
            if key == nil {
                key = try usrSvc.saveKey(for: usr)
            }
            
            guard let key = key else {
                completionHandler(.failure(KeyriErrors.keyriSdkError))
                return
            }

            
            let keyriService = KeyriService()
            keyriService.getSessionInfo(appKey: appKey, sessionId: sessionId, associationKey: key) { result in
                switch result {
                    
                case .success(let data):
                    do {
                        let session = try JSONDecoder().decode(Session.self, from: data)
                        session.userPublicKey = key.derRepresentation.base64EncodedString()
                        session.appKey = appKey
                        self.activeSession = session
                        completionHandler(.success(session))
                    } catch {
                        completionHandler(.failure(error))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
            
            
        } catch {
            completionHandler(.failure(error))
        }

    }
    
    public func easyKeyriAuth(publicUserId: String, appKey: String, payload: String, completion: @escaping ((Result<Bool, Error>) -> ())) {
        let scanner = Scanner()
        scanner.completion = { str in
            if let url = URL(string: str) {
                self.processLink(url: url, publicUserId: publicUserId, appKey: appKey, payload: payload) { result in
                    completion(result)
                }
            } else {
                completion(.failure(KeyriErrors.keyriSdkError))
            }
        }
        scanner.show()
    }
    
    public func processLink(url: URL, publicUserId: String, appKey: String, payload: String, completion: @escaping ((Result<Bool, Error>) -> ())) {
        let sessionId = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""

        let keyri = Keyri() // Be sure to import the SDK at the top of the file
        keyri.initiateQrSession(username: publicUserId, sessionId: sessionId, appKey: appKey) { res in
            switch res {
            case .success(let session):
                DispatchQueue.main.async {
                    // You can optionally create a custom screen and pass the session ID there. We recommend this approach for large enterprises
                    session.payload = payload
                    let root = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
                    let cs = ConfirmationScreenUIView(session: session) { bool in
                        root?.dismiss(animated: true)
                        completion(.success(bool))
                    }
                    
                    root?.present(cs.vc, animated: true)
                }
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
            
        }
    }
    
    public func initializeDefaultConfirmationScreen(session: Session, payload: String, completion: @escaping (Bool) -> ()) {

        session.payload = payload
        let root = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        let view = ConfirmationScreenUIView(session: session, dismissalDelegate: completion)
        
        root?.present(view.vc, animated: true)

        
    }
    
    public func generateAssociationKey(username: String = "ANON") throws -> P256.Signing.PublicKey {
        let usrSvc = UserService()
        return try usrSvc.saveKey(for: username)
    }
    
    public func generateUserSignature(for username: String = "ANON", data: Data) throws -> P256.Signing.ECDSASignature {
        let usrSvc = UserService()
        return try usrSvc.sign(username: username, dataForSignature: data)
    }
    
    public func getAssociationKey(username: String = "ANON") throws -> P256.Signing.PublicKey? {
        let usrSvc = UserService()
        return try usrSvc.verifyExistingUser(username: username)
    }
    
    public func removeAssociationKey(publicUserId: String = "ANON") throws {
        let keychain = Keychain(service: "com.keyri")
        try keychain.remove(key: publicUserId)
    }
    
    public func listAssociactionKeys() -> [String:String]? {
        let keychain = Keychain(service: "com.keyri")
        return keychain.listKeys()
    }
    
    public func listUniqueAccounts() -> [String:String]? {
        guard let list = listAssociactionKeys() else { return nil }
        
        return list.filter({$0.key != "ANON"})
    }
    
    public func createDeviceFingerprint(username: String, appKey: String) throws {
        guard let deviceInfo = deviceInfo().getDeviceInfo(username: username) else { throw KeyriErrors.accountNotFoundError }
        
        print("calling it")
        print(KeyriService().createDevice(appKey: appKey, dict: deviceInfo))
    }
    
    public func sendEvent(appKey: String, username: String = "ANON", eventType: String = "Default", success: Bool = true) {
        print("SUPPPPPPP")
        KeyriService().sendEvent(appKey: appKey, username: username)
    }
}
