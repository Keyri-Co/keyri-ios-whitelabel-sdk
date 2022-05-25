open class KeyriRegistration {
    
    public init() {}
    
    public func registerOrLogin(for username: String, sessionId: String, appKey: String, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        
        // verify user
        // make get
        let keyriService = KeyriService()
        keyriService.getSessionInfo { result in
            switch result {
                
            case .success(let data):
                print(data)
                completionHandler(.success(data))
            case .failure(_):
                print("fail")
            }
        }
        // create session object
        // return VM as result
    }
}


open class vm {
    public func abc() -> Int {
        return 69
    }
}
