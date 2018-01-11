//
//  API.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/11/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import Foundation

extension LastFM {
    
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
                        completion(.failure(LastFM.ErrorType.badResponse))
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
    
}
