//
//  LastFmScrobbleService.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/25/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import CocoaLumberjack

class LastFmScrobbleService: ScrobbleService {
    var isLoggedIn: Bool {
        return sessionKey != nil
    }
    var currentUserName: String?
    private var sessionKey: String?
    private(set) var api: LastFMAPI
    
    init(api: LastFMAPI) {
        self.api = api
    }
    
    func authenticate(username: String, password: String, completion: @escaping (SignInError?) -> ()) {
        api.getMobileSession(username: username, password: password) { result in
            switch result {
            case .success(let session):
                self.startSession(sessionKey: session.key, username: username)
                completion(nil)
            case .failure(let error):
                if case let LastFM.ErrorType.error(code, _) = error, code == 4 {
                    completion(.authenticationFailed)
                } else {
                    completion(.other(message: error.localizedDescription))
                }                
            }
        }
    }
    
    func startSession(sessionKey: String?, username: String) {
        self.sessionKey = sessionKey
        currentUserName = username
        
        UserDefaults.standard.set(self.sessionKey, forKey: "sessionKey")
        UserDefaults.standard.set(username, forKey: "username")
        
        NotificationCenter.default.post(name: .signedIn, object: nil)
    }
    
    func signOut() {
        sessionKey = nil
        currentUserName = nil
        api.sessionKey = nil
        
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "sessionKey")
        
        NotificationCenter.default.post(name: .signedOut, object: nil)
    }
    
    func resumeSession() {
        sessionKey = UserDefaults.standard.string(forKey: "sessionKey")
        currentUserName = UserDefaults.standard.string(forKey: "username")
        api.sessionKey = sessionKey
    }
    
    func scrobble(songs: [PlayedSong], completion: @escaping ([PlayedSong], Error?) -> ()) {
        DDLogDebug("Scrobbling \(songs.count) songs")
        
        guard songs.count > 0 else {
            return completion([], nil)
        }
        
        guard isLoggedIn else {
            let error = LastFM.ErrorType.notSignedIn
            return completion(markNotScrobbled(songs: songs, with: error), error)
        }

        let batches = makeBatches(from: songs)
        scrobble(batches: batches, completion: completion)
    }
    
    private func makeBatches(from songs: [PlayedSong]) -> [[PlayedSong]] {
        let batchSize = 50
        var batches: [[PlayedSong]] = []
        for index in stride(from: 0, to: songs.count, by: batchSize) {
            let start = index
            let end = min(start + batchSize, songs.count)
            let songBatch: [PlayedSong] = Array(songs[start..<end])
            batches.append(songBatch)
        }
        return batches
    }
    
    private func scrobble(batches: [[PlayedSong]], completion: @escaping ([PlayedSong], Error?) -> ()) {
        DDLogDebug("Scrobbling \(batches.count) batches")
        
        let group = DispatchGroup()
        var updatedSongs: [PlayedSong] = []
        var scrobbleError: Error?
        
        for batch in batches {
            group.enter()
            scrobble(batch: batch) { (updatedBatch, error) in
                updatedSongs.append(contentsOf: updatedBatch)
                if scrobbleError == nil {
                    scrobbleError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(updatedSongs, scrobbleError)
        }
    }
    
    private func scrobble(batch: [PlayedSong], completion: @escaping ([PlayedSong], Error?) -> ()) {
        DDLogDebug("Scrobbling batch with \(batch.count) songs")
        
        for song in batch {
            DDLogDebug("Scrobbling \(song.track ?? "") by \(song.artist ?? "") last played \(song.date)")
        }
        
        api.scrobble(songs: batch) { result in
            // Error codes 11, 16 mean we need to try again. Halt the batch submission and print a message "Temporarily unavailable, try again."
            // Error code 9 means bad session, need to re-auth. Halt the batch and print "bad session" or maybe prompt to relogin?
            // All other error code mean the request was malformed in some way and should not be retried
            // All of the above should halt the batch and inform the interactor to present an error.
            // However, any songs that WERE scrobbled should be remembered - updated in the database; NOT scrobbled again
            
            switch result {
            case .success(let response):
                DDLogDebug("Batch scrobbled successfully")
                completion(self.markScrobbled(songs: batch), nil)
            case .failure(let error):
                DDLogDebug("Error scrobbling batch: \(error)")
                completion(self.markFailed(songs: batch, with: error), error)
            }
        }
    }

    func markScrobbled(songs: [PlayedSong]) -> [PlayedSong] {
        var _songs = songs
        for i in 0..<_songs.count {
            _songs[i].scrobbled()
        }
        return _songs
    }
    
    func markFailed(songs: [PlayedSong], with error: Error) -> [PlayedSong] {
        var _songs = songs
        for i in 0..<_songs.count {
            _songs[i].failedToScrobble(reason: "\(error)")
        }
        return _songs
    }
    
    func markNotScrobbled(songs: [PlayedSong], with error: LastFM.ErrorType) -> [PlayedSong] {
        var _songs = songs
        for i in 0..<_songs.count {
            _songs[i].notScrobbled(reason: "\(error)")
        }
        return _songs
    }
    
    func love(song: PlayedSong, completion: @escaping (Error?) -> ()) {
        api.love(song: song) { result in
            switch result {
            case .success: completion(nil)
            case .failure(let error): completion(error)
            }
        }
    }
}

