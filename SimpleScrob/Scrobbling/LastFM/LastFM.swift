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
import CocoaLumberjack

protocol LastFMAPI {
    var sessionKey: String? { get set }
    func getMobileSession(username: String, password: String, completion: @escaping (LastFM.Result<LastFM.GetMobileSessionResponse>) -> ())
    func scrobble(songs: [PlayedSong], completion: @escaping (LastFM.Result<LastFM.ScrobbleResponse>) -> ())
    func love(song: PlayedSong, completion: @escaping (LastFM.Result<LastFM.LoveResponse>) -> ())
}

protocol LastFMAPIEngine {
    func post(method: String, params: [String: String], completion: @escaping (LastFM.Result<[String: Any]>) -> ())
}

struct LastFM {
    enum ErrorType: Error, LocalizedError, CustomStringConvertible {
        case error(code: Int, message: String?)
        case badResponse
        case notSignedIn
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .error(let code, let message): return "Error \(code): \(message ?? "")"
            case .badResponse: return "There was an unexpected response from Last.fm"
            case .notSignedIn: return "Not signed in"
            case .unknown: return "An unknown error has occurred"
            }
        }
        
        var description: String {
            return errorDescription ?? ""
        }
    }
    
    enum Result<T> {
        case success(T)
        case failure(Error)
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
    
    struct LoveResponse {
        
    }
}

class FakeLastFM: LastFMAPI {
    var sessionKey: String?
    
    func getMobileSession(username: String, password: String, completion: @escaping (LastFM.Result<LastFM.GetMobileSessionResponse>) -> ()) {
        print("getMobileSession. Username = '\(username)', Password = '\(password)'")
        completion(.success(LastFM.GetMobileSessionResponse(name: username, key: "123456", subcriber: false)))
//        completion(.failure(LastFM.ErrorType.error(code: 11, message: "Things and stuff")))
    }
    
    func scrobble(songs: [PlayedSong], completion: @escaping (LastFM.Result<LastFM.ScrobbleResponse>) -> ()) {
        print("Scrobbling \(songs.count) songs")
        for song in songs {
            print("Scrobbling \(song.track ?? "") by \(song.artist ?? "")")
        }
        delay(seconds: 1.2) {
//            completion(.failure(LastFM.ErrorType.error(code: 77, message: "YOU SUCK")))
            completion(.success(LastFM.ScrobbleResponse(accepted: [], ignored: [])))
        }
    }
    
    func love(song: PlayedSong, completion: @escaping (LastFM.Result<LastFM.LoveResponse>) -> ()) {
        print("LOVE: \(song.track ?? "N/A")")
        completion(.success(LastFM.LoveResponse()))
    }
}
