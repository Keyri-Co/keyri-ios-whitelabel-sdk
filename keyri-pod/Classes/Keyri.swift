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
                        var session = try JSONDecoder().decode(Session.self, from: data)
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
    
    public func generateAssociationKey(username: String) throws -> P256.Signing.PublicKey {
        let usrSvc = UserService()
        return try usrSvc.saveKey(for: username)
    }
    
    public func generateUserSignature(for username: String, data: Data) throws -> P256.Signing.ECDSASignature {
        let usrSvc = UserService()
        return try usrSvc.sign(username: username, data: data)
    }
    
    public func getAssociationKey(username: String) throws -> P256.Signing.PublicKey? {
        let usrSvc = UserService()
        return try usrSvc.verifyExistingUser(username: username)
    }
    
    public func listAssociactionKeys() -> [String:String]? {
        let keychain = Keychain(service: "com.keyri")
        return keychain.listKeys()
    }
}
