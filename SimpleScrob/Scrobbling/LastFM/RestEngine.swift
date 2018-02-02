//
//  RestEngine.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/11/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Alamofire

extension LastFM {
    
    class RestEngine: LastFMAPIEngine {
        let apiKey: String
        let secret: String
        
        init(apiKey: String, secret: String) {
            self.apiKey = apiKey
            self.secret = secret
        }
        
        func post(method: String, params: [String: String], completion: @escaping (LastFM.Result<[String: Any]>) -> ()) {
            let params = makeParams(method: method, params: params)
            
            DDLogDebug("POST \(method) \(params.debugDescription)")
            
            Alamofire
                .request("https://ws.audioscrobbler.com/2.0", method: .post, parameters: params)
                .responseJSON { response in
                    DDLogVerbose(response.debugDescription)
                    
                    if let json = response.result.value as? [String: Any] {
                        if let code = json["error"] as? Int {
                            let error = LastFM.ErrorType.error(code: code, message: json["message"] as? String)
                            completion(.failure(error))
                        } else{
                            completion(.success(json))
                        }
                    } else {
                        completion(.failure(response.error ?? LastFM.ErrorType.unknown))
                    }
            }
        }
        
        func makeParams(method: String, params: [String: String]) -> [String: String] {
            var _params = params
            _params["method"] = method
            _params["api_key"] = apiKey
            _params["api_sig"] = sign(_params)
            _params["format"] = "json"
            return _params
        }
        
        func sign(_ params: [String: String]) -> String {
            var _params = params
            var signature = ""
            for key in _params.keys.sorted() {
                signature += key
                signature += _params[key] ?? ""
            }
            signature += secret
            DDLogVerbose(signature)
            return MD5(string: signature)
        }
        
        func MD5(string: String) -> String {
            let messageData = string.data(using:.utf8)!
            var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
            
            _ = digestData.withUnsafeMutableBytes {digestBytes in
                messageData.withUnsafeBytes {messageBytes in
                    CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
                }
            }
            
            return digestData.map { String(format: "%02hhx", $0) }.joined()
        }
    }
    
}
