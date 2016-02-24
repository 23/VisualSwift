import IDZSwiftCommonCrypto

class VisualSwiftUtils {
    static let allowedChars = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~")
    static let alphaNumericLetters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    static func generateAlphanumericOfLength(length: Int) -> String {
        var randomString = ""
        for (var i=0; i < length; i++){
            let length = UInt32(alphaNumericLetters.characters.count)
            let rand = arc4random_uniform(length)
            let char = (alphaNumericLetters as NSString).substringWithRange(NSRange(location: Int(rand), length: 1))
            randomString.appendContentsOf(char)
        }
        return randomString
    }
    
    static func base64(str: String) -> String {
        let data = NSMutableData(capacity: str.characters.count / 2)
        for var index = str.startIndex; index < str.endIndex; index = index.successor().successor() {
            let byteString = str.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            data?.appendBytes([num] as [UInt8], length: 1)
        }
        let options = NSDataBase64EncodingOptions(rawValue: 0)
        let base64Encoded = data?.base64EncodedStringWithOptions(options)
        
        return base64Encoded!
    }
    static func hmacsha1(str: String, key: String) -> String {
        let digest = HMAC(algorithm: .SHA1, key: key.dataUsingEncoding(NSASCIIStringEncoding)!).update(str)?.final()
        let digString = hexStringFromArray(digest!)
        
        return base64(digString)
    }
    
    static func urlEncode(string: String) -> String {
        return string.stringByAddingPercentEncodingWithAllowedCharacters(allowedChars)!
    }
    static func urlDecode(string: String) -> String {
        if let decodedString = string.stringByRemovingPercentEncoding {
            return decodedString
        } else {
            return string
        }
    }
    
    static func sortedEncodedParameters(parameters: NSMutableDictionary) -> String {
        let sortedNames = (parameters.allKeys as! [String]).sort()
        var parameterArray = [String]()
        for name in sortedNames {
            let value = String(parameters.objectForKey(name)!)
            parameterArray.append("\(self.urlEncode(name))=\(self.urlEncode(value))")
        }
        let result = parameterArray.joinWithSeparator("&")
        return result
    }
    static func sortedEncodedParameters(parameters: [String: String]) -> String {
        let sortedNames = parameters.keys.sort()
        var parameterArray = [String]()
        for name in sortedNames {
            if let value = parameters[name] {
                parameterArray.append("\(self.urlEncode(name))=\(self.urlEncode(value))")
            }
        }
        let result = parameterArray.joinWithSeparator("&")
        return result
    }
    static func parseParameters(parameterString: String) -> [String: String] {
        var parameterDictionary = [String: String]()
        let componentArray = parameterString.componentsSeparatedByString("&")
        for component in componentArray {
            let keyValueArray = component.componentsSeparatedByString("=")
            if keyValueArray.count == 2 {
                parameterDictionary[keyValueArray[0]] = keyValueArray[1]
            }
        }
        return parameterDictionary
    }
}