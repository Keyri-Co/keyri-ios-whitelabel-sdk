import CryptoKit

open class Keyri {
    
    public init() {}
    
    public func initializeQrSession(username: String?, sessionId: String, appKey: String, completionHandler: @escaping (Result<Session, Error>) -> Void) {
        let usrSvc = UserService()
        let usr = username ?? "ANON"
        
        do {
            var key = try usrSvc.verifyExistingUser(username: usr)
            if key == nil {
                key = try usrSvc.saveKey(for: usr)
            }
            
            let keyriService = KeyriService()
            keyriService.getSessionInfo(appKey: appKey, sessionId: sessionId) { result in
                switch result {
                    
                case .success(let data):
                    do {
                        let session = try JSONDecoder().decode(Session.self, from: data)
                        session.userPublicKey = key!.derRepresentation.base64EncodedString()
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
    
    public func easyKeyriAuth(publicUserId: String, appKey: String, payload: String, completion: @escaping ((Bool) -> ())) {
        let scanner = Scanner()
        scanner.completion = { str in
            if let url = URL(string: str) {
                self.processLink(url: url, publicUserId: publicUserId, appKey: appKey, payload: payload) { bool in
                    completion(bool)
                }
            }
        }
        scanner.show()
    }
    
    public func processLink(url: URL, publicUserId: String, appKey: String, payload: String, completion: @escaping ((Bool) -> ())) {
        let sessionId = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: { $0.name == "sessionId" })?.value ?? ""

        let keyri = Keyri() // Be sure to import the SDK at the top of the file
        keyri.initializeQrSession(username: publicUserId, sessionId: sessionId, appKey: appKey) { res in
            switch res {
            case .success(let session):
                DispatchQueue.main.async {
                    // You can optionally create a custom screen and pass the session ID there. We recommend this approach for large enterprises
                    session.payload = payload
                    let root = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
                    let cs = ConfirmationScreenUIView(session: session) { bool in
                        root?.dismiss(animated: true)
                        completion(bool)
                    }
                    
                    root?.present(cs.vc, animated: true)
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    public func generateAssociationKey(username: String = "ANON") throws -> P256.Signing.PublicKey {
        let usrSvc = UserService()
        return try usrSvc.saveKey(for: username)
    }
    
    public func generateUserSignature(for username: String = "ANON", data: Data) throws -> P256.Signing.ECDSASignature {
        let usrSvc = UserService()
        return try usrSvc.sign(username: username, data: data)
    }
    
    public func getAssociationKey(username: String = "ANON") throws -> P256.Signing.PublicKey? {
        let usrSvc = UserService()
        return try usrSvc.verifyExistingUser(username: username)
    }
    
    public func listAssociactionKeys() -> [String:String]? {
        let keychain = Keychain(service: "com.keyri")
        return keychain.listKeys()
    }
}
