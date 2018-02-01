//
//  API.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/11/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import Foundation
import SwiftyJSON

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
                    let response = self.buildScrobbleResponse(json: JSON(json))
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        private func buildScrobbleResponse(json: JSON) -> LastFM.ScrobbleResponse {
            var accepted: [LastFM.ScrobbleResponse.Scrobble] = []
            var ignored: [LastFM.ScrobbleResponse.Scrobble] = []
            
            let acceptedCount = json["scrobbles"]["@attr"]["accepted"].intValue
            let ignoredCount = json["scrobbles"]["@attr"]["ignored"].intValue
            print("Accepted: \(acceptedCount), Ignored: \(ignoredCount)")
            
            let scrobblesJson = json["scrobbles"]["scrobble"].arrayValue
            for scrobbleJson in scrobblesJson {
                if scrobbleJson["ignoredMessage"]["code"].intValue == 0 {
                    accepted.append(self.makeScrobble(json: scrobbleJson))
                } else {
                    ignored.append(self.makeScrobble(json: scrobbleJson))
                }
            }

            return LastFM.ScrobbleResponse(accepted: accepted, ignored: ignored)
        }
        
        private func makeScrobble(json: JSON) -> LastFM.ScrobbleResponse.Scrobble {
            var s = LastFM.ScrobbleResponse.Scrobble()
            s.timestamp = json["timestamp"].int
            s.track = json["track"]["#text"].string
            s.artist = json["artist"]["#text"].string
            s.album = json["album"]["#text"].string
            s.ignoredMessage = json["ignoredMessage"]["#text"].string
            s.ignoredCode = json["ignoredMessage"]["code"].int
            return s
        }
        
        func love(song: PlayedSong, completion: @escaping (Result<LoveResponse>) -> ()) {
            var params: [String: String] = [:]
            params["sk"] = sessionKey
            params["track"] = song.track
            params["artist"] = song.artist
            
            engine.post(method: "track.love", params: params) { result in
                switch result {
                case .success: completion(.success(LoveResponse()))
                case .failure(let error): completion(.failure(error))
                }
            }
        }
    }
    
}
