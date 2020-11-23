//
//  GoogleTranslation.swift
//  GoogleTranslate
//
//  Created by Ashish-BigStep on 8/20/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

struct LanguageDetectionResponse {
    public var language: String
    public var isReliable: Bool
    public var confidence: Double
}

struct LanguageResponse {
    public var language: String
    public var name: String
}

class CHGoogleTranslation {
    
    static let baseUrl = "https://translation.googleapis.com/language/translate/v2"
    
    static var googleTranslateApiKey = ""
    static var isGoogleTranslationModuleEnabled = false
    
    static var shared: CHGoogleTranslation = {
        let instance = CHGoogleTranslation()
        return instance
    }()
    
    func translateRequestedText(string: String, completion: @escaping (String?,Error?) -> Void) {
        
        let allDeviceLanguages = Locale.preferredLanguages
        guard let firstLanguage = allDeviceLanguages.first else {
            return
        }
        
        let localeComponent = Locale.components(fromIdentifier: firstLanguage)
        let languageCode = localeComponent["kCFLocaleLanguageCodeKey"] ?? "en"
        
        
        self.translate(originalText: string, requestedLanguage: languageCode, completion: {(translatedText,error) in
            DispatchQueue.main.async {
                completion(translatedText,error)
            }
        })
    }
    
    private func translate(originalText: String, requestedLanguage: String, completion: @escaping (String?,Error?) -> Void) {
        
        var parameters = [String:Any]()
        parameters.updateValue(CHGoogleTranslation.googleTranslateApiKey, forKey: "key")
        parameters.updateValue(originalText, forKey: "q")
        parameters.updateValue(requestedLanguage, forKey: "target")
        parameters.updateValue("text", forKey: "format")
        parameters.updateValue("base", forKey: "model")
        
        guard let baseUrl = URL(string: CHGoogleTranslation.baseUrl) else {
            return
        }
        var urlRequest = URLRequest(url: baseUrl)
        guard var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
            return
        }
        let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&"} ?? "") + query(parameters)
        urlComponents.percentEncodedQuery = percentEncodedQuery
        urlRequest.url = urlComponents.url
        urlRequest.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            guard error == nil else {
                completion(nil,error)
                return
            }
            
            guard let responseData = data else {
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                do {
                    if let errorJsonObject = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? NSDictionary {
                        if let errorDic = errorJsonObject.value(forKey: "error") as? NSDictionary {
                            let errorMessage = errorDic.value(forKey: "message") as? String
                            let error = GoogleTranslationError(message: errorMessage)
                            completion(nil,error)
                        }
                    }
                } catch {
                    completion(nil,error)
                }
                return
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? NSDictionary {
                    if let responseDataDictionary = jsonObject.value(forKey: "data") as? NSDictionary {
                        if let translationArray = responseDataDictionary.value(forKey: "translations") as? NSArray {
                            if let firstTranslation = translationArray.firstObject as? NSDictionary {
                                let translatedText = firstTranslation.value(forKey: "translatedText") as? String
                                completion(translatedText,nil)
                            }
                        } else {
                            let error = GoogleTranslationError(message: "Wrong Json Object.")
                            completion(nil,error)
                        }
                    } else {
                        let error = GoogleTranslationError(message: "Wrong Json Object.")
                        completion(nil,error)
                    }
                } else {
                    let error = GoogleTranslationError(message: "Wrong Json Object.")
                    completion(nil,error)
                }
            } catch {
                print(error.localizedDescription)
                completion(nil,error)
            }
        }
        task.resume()
    }
    
    private func detect(originalText: String, completion: @escaping ([LanguageDetectionResponse]?,Error?) -> Void) {
        var parameters = [String:Any]()
        parameters.updateValue(CHGoogleTranslation.googleTranslateApiKey, forKey: "key")
        parameters.updateValue(originalText, forKey: "q")
        
        guard let baseUrl = URL(string: CHGoogleTranslation.baseUrl + "/detect") else {
            return
        }
        var urlRequest = URLRequest(url: baseUrl)
        
        guard var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
            return
        }
        let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&"} ?? "") + query(parameters)
        urlComponents.percentEncodedQuery = percentEncodedQuery
        urlRequest.url = urlComponents.url
        urlRequest.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            guard let responseData = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode, error == nil else {
                completion(nil,error)
                return
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? NSDictionary {
                    if let responseDataDictionary = jsonObject.value(forKey: "data") as? NSDictionary {
                        if let detectionArray = responseDataDictionary.value(forKey: "detections") as? [[[String:Any]]] {
                            var allDetections = [LanguageDetectionResponse]()
                            for languageDetections in detectionArray {
                                for detection in languageDetections {
                                    let confidence = detection["confidence"] as? Double ?? 0.0
                                    let isReliable = detection["isReliable"] as? Bool ?? false
                                    let languageCode = detection["language"] as? String ?? "en"
                                    let detectionObject = LanguageDetectionResponse(language: languageCode, isReliable: isReliable, confidence: confidence)
                                    allDetections.append(detectionObject)
                                }
                            }
                            completion(allDetections,nil)
                        } else {
                            completion(nil, NSError(domain: "Wrong Json Object", code: 412, userInfo: nil))
                        }
                    } else {
                        completion(nil, NSError(domain: "Wrong Json Object", code: 412, userInfo: nil))
                    }
                } else {
                    completion(nil, NSError(domain: "Wrong Json Object", code: 412, userInfo: nil))
                }
            } catch {
                print(error.localizedDescription)
                completion(nil,error)
            }
        }
        task.resume()
    }
    
    private func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []

        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: self.arrayEncode(key: key), value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape(self.boolEncode(value: value.boolValue))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape(self.boolEncode(value: bool))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }

        return components
    }
    
    func arrayEncode(key: String) -> String {
        return "\(key)[]"
    }
    
    func boolEncode(value: Bool) -> String {
        return value ? "1" : "0"
    }
    
    public func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        var escaped = ""

        //==========================================================================================================
        //
        //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
        //  hundred Chinese characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
        //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
        //  info, please refer to:
        //
        //      - https://github.com/Alamofire/Alamofire/issues/206
        //
        //==========================================================================================================

        if #available(iOS 8.3, *) {
            escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        } else {
            let batchSize = 50
            var index = string.startIndex

            while index != string.endIndex {
                let startIndex = index
                let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
                let range = startIndex..<endIndex

                let substring = string[range]

                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? String(substring)

                index = endIndex
            }
        }

        return escaped
    }
}



