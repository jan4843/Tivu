extension URL {
    struct BasicAuth {
        let user: String?
        let password: String?
    }
    
    func removingBasicAuth() -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        urlComponents.basicAuth = BasicAuth(user: nil, password: nil)
        return urlComponents.url!
    }
}

extension URLComponents {
    var basicAuth: URL.BasicAuth {
        get {
            URL.BasicAuth(user: self.user, password: self.password)
        }
        set {
            let user = newValue.user ?? ""
            let password = newValue.password ?? ""
            self.user = user.isEmpty ? nil : user
            self.password = password.isEmpty ? nil : password
        }
    }
}
