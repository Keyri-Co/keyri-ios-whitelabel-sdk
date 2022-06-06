open class Keyri {
    
    public init() {}
    
    public func registerOrLogin(for username: String?, sessionId: String, appKey: String, completionHandler: @escaping (Result<Session, Error>) -> Void) {
        let usrSvc = UserService()
        let usr = username ?? "ANON"
        
        do {
            let key = try usrSvc.verifyExistingUser(username: usr) ?? usrSvc.saveKey(for: usr)
            
            let keyriService = KeyriService()
            keyriService.getSessionInfo(appKey: appKey, sessionId: sessionId) { result in
                switch result {
                    
                case .success(let data):
                    do {
                        var session = try JSONDecoder().decode(Session.self, from: data)
                        session.userPublicKey = key.derRepresentation.base64EncodedString()
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
}
