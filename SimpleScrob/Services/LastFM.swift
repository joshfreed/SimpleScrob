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

protocol LastFMAPI {
    var sessionKey: String? { get set }
    func getMobileSession(username: String, password: String, completion: @escaping (LastFM.Result<LastFM.GetMobileSessionResponse>) -> ())
    func scrobble(songs: [PlayedSong], completion: @escaping (LastFM.Result<LastFM.ScrobbleResponse>) -> ())
}

protocol LastFMAPIEngine {
    func post(method: String, params: [String: String], completion: @escaping (LastFM.Result<[String: Any]>) -> ())
}

struct LastFM {
    enum ErrorType: Error {
        case error(code: Int, message: String?)
        case badResponse
        case notSignedIn
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

    class API: LastFMAPI {
        let engine: LastFMAPIEngine
        var sessionKey: String?

        init(engine: LastFMAPIEngine) {
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
                    if let session = json["session"] as? [String: Any], let key = session["key"] as? String {
                        self.sessionKey = key
                        let response = LastFM.GetMobileSessionResponse(
                            name: session["name"] as? String,
                            key: key,
                            subcriber: session["subscriber"] as? Bool ?? false
                        )
                        completion(.success(response))
                    } else {
                        completion(.failure(.badResponse))
                    }
                case .failure(let error): completion(.failure(error))
                }
            }
        }
        
        func scrobble(songs: [PlayedSong], completion: @escaping (Result<ScrobbleResponse>) -> ()) {
            guard songs.count > 0 && songs.count <= 50 else {
                return
            }
            
            var params: [String: String] = [:]
            params["sk"] = sessionKey
            for (index, song) in songs.enumerated() {
                params["artist[\(index)]"] = song.artist
                params["album[\(index)]"] = song.album
                params["track[\(index)]"] = song.track
                params["timestamp[\(index)]"] = song.scrobbleTimestamp
            }
            
            engine.post(method: "track.scrobble", params: params) { result in
                switch result {
                case .success(let json):
                    let scrobblesTag = json["scrobbles"] as? [String: Any]
                    let scrobbles = scrobblesTag?["scrobble"] as? [[String: Any]]
                    var accepted: [LastFM.ScrobbleResponse.Scrobble] = []
                    var ignored: [LastFM.ScrobbleResponse.Scrobble] = []
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
                        ignored: ignored
                    )
                    completion(.success(response))
                case .failure(let error): completion(.failure(error))
                }
            }
        }
    }
    
    class RestEngine: LastFMAPIEngine {
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
                            completion(.failure(error))
                        } else{
                            completion(.success(json))
                        }
                    } else {
                        completion(.failure(LastFM.ErrorType.badResponse))
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

class FakeLastFM: LastFMAPI {
    var sessionKey: String?
    
    func getMobileSession(username: String, password: String, completion: @escaping (LastFM.Result<LastFM.GetMobileSessionResponse>) -> ()) {
        print("getMobileSession. Username = '\(username)', Password = '\(password)'")
        completion(.success(LastFM.GetMobileSessionResponse(name: username, key: "123456", subcriber: false)))
    }
    
    func scrobble(songs: [PlayedSong], completion: @escaping (LastFM.Result<LastFM.ScrobbleResponse>) -> ()) {
        print("Scrobbling \(songs.count) songs")
        for song in songs {
            print("Scrobbling \(song.track ?? "") by \(song.artist ?? "")")
        }
//        completion(.failure(.error(code: 77, message: "YOU SUCK")))
        delay(seconds: 1.2) {
            completion(.success(LastFM.ScrobbleResponse(accepted: [], ignored: [])))
        }
    }
}
