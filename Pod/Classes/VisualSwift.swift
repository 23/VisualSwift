import Alamofire

public class VisualSwift {
    var domain: String!
    var scheme: String!
    
    var APIConsumerKey = ""
    var APIConsumerSecret = ""
    
    var APIAccessToken = ""
    var APIAccessTokenSecret = ""
    
    let APIXAuthURL = "https://api.23video.com/oauth/access_token"
    
    public init(domain: String, scheme: String) {
        self.domain = domain
        self.scheme = scheme
    }
    public convenience init(domain: String, scheme: String, credentials: [String: String]) {
        self.init(domain: domain, scheme: scheme)
        if let consumerKey = credentials["consumer_key"] {
            self.APIConsumerKey = consumerKey
        }
        if let consumerSecret = credentials["consumer_secret"] {
            self.APIConsumerSecret = consumerSecret
        }
        if let accessToken = credentials["access_token"] {
            self.APIAccessToken = accessToken
        }
        if let accessTokenSecret = credentials["access_token_secret"] {
            self.APIAccessTokenSecret = accessTokenSecret
        }
    }
    
    func getAuthorizationHeader(urlString: String, var parameters: [String: String], HTTPMethod: String) -> [String: String] {
        let nonce = VisualSwiftUtils.generateAlphanumericOfLength(32)
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        parameters["oauth_consumer_key"] = APIConsumerKey
        parameters["oauth_signature_method"] = "HMAC-SHA1"
        parameters["oauth_version"] = "1.0"
        parameters["oauth_token"] = APIAccessToken
        parameters["oauth_nonce"] = nonce
        parameters["oauth_timestamp"] = String(timestamp)
        
        let url = NSURL(string: urlString)!
        
        let realm = "\(url.scheme)://\(url.host!)"
        let baseUrl = "\(realm)\(url.path!)"
        
        let escapedParameters = VisualSwiftUtils.sortedEncodedParameters(parameters)
        let signatureBase = "\(HTTPMethod)&\(VisualSwiftUtils.urlEncode(baseUrl))&\(VisualSwiftUtils.urlEncode(escapedParameters))"
        
        let signatureKey = "\(VisualSwiftUtils.urlEncode(APIConsumerSecret))&\(VisualSwiftUtils.urlEncode(APIAccessTokenSecret))"
        
        let signature = VisualSwiftUtils.hmacsha1(signatureBase, key: signatureKey)
        
        let authorization =  [
            "OAuth realm=\"\(baseUrl)\", ",
            "oauth_consumer_key=\"\(APIConsumerKey)\", ",
            "oauth_token=\"\(APIAccessToken)\", ",
            "oauth_signature_method=\"HMAC-SHA1\", ",
            "oauth_signature=\"\(VisualSwiftUtils.urlEncode(signature))\", ",
            "oauth_timestamp=\"\(timestamp)\", ",
            "oauth_nonce=\"\(nonce)\", ",
            "oauth_version=\"1.0\""
            ].joinWithSeparator("")
        
        return ["Authorization": authorization]
    }
    
    public func request(endpoint: String, parameters: [String: String], method: String, useCache: Bool, callback: (Result<AnyObject, NSError>) -> Void) -> Void {
        var parametersDictionary: [String: String] = ["format": "json", "raw": "1"]
        if !useCache || true {
            parametersDictionary["_"] = String(Int(NSDate().timeIntervalSince1970))
        }
        for (key, value) in parameters {
            parametersDictionary[key] = value
        }
        let urlString = "\(scheme)://\(domain)\(endpoint)"
        
        var authorizationHeader = [String: String]()
        if APIAccessToken != "" {
            authorizationHeader =  getAuthorizationHeader(urlString, parameters: parametersDictionary, HTTPMethod: method)
        }
        let _method = (method == "GET" ? Alamofire.Method.GET : Alamofire.Method.POST)
        
        Alamofire.request(_method, urlString, parameters: parametersDictionary, encoding: .URL, headers: authorizationHeader).responseJSON {
            response in
            callback(response.result)
        }
        
    }
    public func request(endpoint: String, callback: (Result<AnyObject, NSError>) -> Void) -> Void {
        request(endpoint, parameters: [String: String](), method: "GET", useCache: true, callback: callback)
    }
    public func request(endpoint: String, parameters: [String: String], callback: (Result<AnyObject, NSError>) -> Void) -> Void {
        request(endpoint, parameters: parameters, method: "GET", useCache: true, callback: callback)
    }
    func request(endpoint: String, parameters: [String: String], method: String, callback: (Result<AnyObject, NSError>) -> Void) -> Void {
        request(endpoint, parameters: parameters, method: method, useCache: true, callback: callback)
    }
    
    public func uploadFile(endpoint: String, parameters: NSDictionary, fileURL: NSURL, progressCallback: (Double) -> Void) {
        let parametersDictionary: NSMutableDictionary = ["format": "json", "raw": "1"]
        for key in parameters.allKeys {
            parametersDictionary[key as! String] = parameters.objectForKey(key)
        }
        Alamofire.upload(
            .POST,
            "\(scheme)://\(domain)\(endpoint)",
            multipartFormData: { multipartFormData in
                for (key, value) in parametersDictionary {
                    multipartFormData.appendBodyPart(data: String(value).dataUsingEncoding(NSUTF8StringEncoding)!, name: key as! String)
                }
                multipartFormData.appendBodyPart(fileURL: fileURL, name: "file")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        }.progress {
                            bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                            let progress: Double = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
                            progressCallback(progress)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
        )
        
    }
    
    public func authenticate(username: String, password: String, callback: (String) -> Void) -> Void {
        let parameters: [String: String] = [
            "x_auth_mode": "client_auth",
            "x_auth_domain": domain,
            "x_auth_username": username,
            "x_auth_password": password,
            "oauth_verifier": "oob"
        ]
        
        let authorizationHeader = getAuthorizationHeader(APIXAuthURL, parameters: parameters, HTTPMethod: "POST")
        
        Alamofire.request(.POST, APIXAuthURL, parameters: parameters, encoding: .URL, headers: authorizationHeader).response {
            request, response, data, error in
            let parameterString = NSString.init(data: data!, encoding: NSUTF8StringEncoding) as! String
            let parameterDictionary = VisualSwiftUtils.parseParameters(parameterString.stringByRemovingPercentEncoding!)
            if let token = parameterDictionary["oauth_token"] {
                self.APIAccessToken = String(token)
                self.APIAccessTokenSecret = String(parameterDictionary["oauth_token_secret"]!)
                callback("Success")
            } else {
                // Error
            }
        }
    }
}