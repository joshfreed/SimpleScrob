//
//  LastFM.swift
//  SimpleScrob
//
//  Created by Josh Freed on 9/30/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import JFLib
import Alamofire

extension Notification.Name {
    static let signedIn = Notification.Name("signedIn")
}

class LastFMService {
    let api: LastFM.API
    
    private(set) var sessionKey: String?
    private(set) var currentUser: User?
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    init(api: LastFM.API) {
        self.api = api
    }
    
    func resume() {
        sessionKey = UserDefaults.standard.string(forKey: "sessionKey")
        api.sessionKey = sessionKey
        
        if let username = UserDefaults.standard.string(forKey: "username") {
            currentUser = User(username: username)
        }
    }
    
    func signIn(username: String, password: String, completion: @escaping (_ success: Bool) -> ()) {
        api.getMobileSession(username: username, password: password) { result in
            switch result {
            case .success(let session):
                print("Login success with session key \(String(describing: self.sessionKey))")
                self.sessionKey = session.key
                self.currentUser = User(username: username)
                UserDefaults.standard.set(self.sessionKey, forKey: "sessionKey")
                UserDefaults.standard.set(username, forKey: "username")
                NotificationCenter.default.post(name: .signedIn, object: nil)
                completion(true)
            case .failure: completion(false)
            }
        }
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "sessionKey")
        currentUser = nil
    }
    
    func submit(songs: [Song], completion: @escaping ((accepted: [Song], ignored: [Song])) -> ()) {
        // Guard: must be logged in
        // Guard: must be connected to the network
        // Submit in batches of 50
        // If any batch fails; abort the operation
        // Response is a list of accepted and ignored songs
        
        // Error codes 11, 16 mean we need to try again. Halt the batch submission and print a message "Temporarily unavailable, try again."
        // Error code 9 means bad session, need to re-auth. Halt the batch and print ""
        // All other error code mean the request was malformed in some way and should not be retried
        
//        completion((accepted: [], ignored: []))
        
        api.scrobble(songs: songs) { result in
            completion((accepted: [], ignored: []))
        }
    }
}

struct LastFM {
    enum ErrorType: Error {
        case error(code: Int, message: String?)
        case badResponse
    }

    enum Result<T> {
        case success(T)
        case failure(LastFM.ErrorType)
    }
    
    struct GetMobileSessionResponse {
        let name: String?
        let key: String?
        let subcriber: Bool
    }
    
    struct ScrobbleResponse {
        let accepted: [Scrobble]
        let ignored: [Scrobble]
        
        struct Scrobble {
            let track: String?
            let artist: String?
            let album: String?
            let albumArtist: String?
            let ignoredMessage: String?
            let ignoredCode: Int?
            let timestamp: Int?
        }
    }

    class API {
        let engine: RestEngine
        var sessionKey: String?

        init(engine: RestEngine) {
            self.engine = engine
        }
        
        func getMobileSession(username: String, password: String, completion: @escaping (Result<GetMobileSessionResponse>) -> ()) {
            let params = [
                "username": username,
                "password": password
            ]
            
            engine.post(method: "auth.getMobileSession", params: params) { result in
                switch result {
                case .success(let json):
                    self.sessionKey = json["key"] as? String
                    let response = LastFM.GetMobileSessionResponse(
                        name: json["name"] as? String,
                        key: json["key"] as? String,
                        subcriber: json["subscriber"] as? Bool ?? false
                    )
                    completion(.success(response))
                case .failure(let error): completion(.failure(error))
                }
            }
        }
        
        func scrobble(songs: [Song], completion: @escaping (Result<ScrobbleResponse>) -> ()) {
            guard songs.count > 0 && songs.count <= 50 else {
                return
            }
            
            var params: [String: String] = [:]
            params["sk"] = sessionKey
            for (index, song) in songs.enumerated() {
                params["artist[\(index)]"] = song.artist
                params["track[\(index)]"] = song.track
                params["timestamp[\(index)]"] = song.scrobbleTimestamp
            }
            
            engine.post(method: "track.scrobble", params: params) { result in
                switch result {
                case .success(let json):
                    let scrobblesTag = json["scrobbles"] as? [String: Any]
                    let scrobbles = scrobblesTag?["scrobble"] as? [[String: Any]]
                    var accepted: [LastFM.ScrobbleResponse.Scrobble] = []
                    if let scrobbles = scrobbles {
                        for scrobble in scrobbles {
                            let s = LastFM.ScrobbleResponse.Scrobble(
                                track: (scrobble["track"] as? [String: Any])?["#text"] as? String,
                                artist: nil,
                                album: nil,
                                albumArtist: nil,
                                ignoredMessage: nil,
                                ignoredCode: nil,
                                timestamp: nil
                            )
                            accepted.append(s)
                        }
                    }
                    let response = LastFM.ScrobbleResponse(
                        accepted: accepted,
                        ignored: []
                    )
                    completion(.success(response))
                case .failure(let error): completion(.failure(error))
                }
            }
        }
    }
    
    class RestEngine {
        let apiKey: String
        let secret: String
        
        init(apiKey: String, secret: String) {
            self.apiKey = apiKey
            self.secret = secret
        }
        
        func post(method: String, params: [String: String], completion: @escaping (LastFM.Result<[String: Any]>) -> ()) {
            let params = makeParams(method: method, params: params)
            
            print(params)
            
            Alamofire.request("https://ws.audioscrobbler.com/2.0", method: .post, parameters: params)
                .responseJSON { response in
                    print(response.debugDescription)
                    
                    if let json = response.result.value as? [String: Any] {
                        print("JSON: \(json)")
                        
                        if let code = json["error"] as? Int {
                            let error = LastFM.ErrorType.error(code: code, message: json["message"] as? String)
                            return completion(.failure(error))
                        } else{
                            return completion(.success(json))
                        }
                    } else {
                        return completion(.failure(LastFM.ErrorType.badResponse))
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
            print(signature)
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
