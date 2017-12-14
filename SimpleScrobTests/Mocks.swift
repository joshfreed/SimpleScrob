//
//  Mocks.swift
//  SimpleScrobTests
//
//  Created by Josh Freed on 10/5/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
@testable import SimpleScrob
import MediaPlayer

class MockMediaLibrary: ScrobbleMediaLibrary {
    private var _isAuthorized = false
    private var _isAuthorizationDenied = false
    
    var _items: [MediaItem] = []
    
    var items: [MediaItem] {
        return _items
    }
    
    func items(since date: Date?) -> [MediaItem] {
        return _items
    }
    
    func authorized() {
        _isAuthorized = true
    }
    
    func isAuthorized() -> Bool {
        return _isAuthorized
    }
    
    func setAuthorizationDenied() {
        _isAuthorizationDenied = true
    }
    
    func authorizationDenied() -> Bool {
        return _isAuthorizationDenied
    }
    
    func requestAuthorization(complete: @escaping () -> ()) {
        
    }
}

class MockDatabase: Database {
    func findById(_ id: PlayedSongId) -> PlayedSong? {
        return nil
    }
    
    func findUnscrobbledSongs(completion: @escaping ([PlayedSong]) -> ()) {
        
    }
    
    func insert(playedSongs: [PlayedSong], completion: @escaping () -> ()) {
        
    }
    
    var saveCallCount = 0
    var savedSongs: [[PlayedSong]] = []
    func save(playedSongs: [PlayedSong], completion: @escaping () -> ()) {
        savedSongs.append(playedSongs)
        saveCallCount += 1
        completion()
    }

    func getRecentScrobbles(completion: @escaping ([PlayedSong]) -> ()) {
        
    }
}

class MockSongScanner: SongScanner {
    var isInitialized: Bool = false
    
    func initializeSongDatabase() {
        
    }
    
    func searchForNewScrobbles() -> [PlayedSong] {
        return []
    }
}

class MockEngine: LastFMAPIEngine {
    func post(method: String, params: [String: String], completion: @escaping (LastFM.Result<[String: Any]>) -> ()) {
        completion(.success([:]))
    }
}

class MockLastFMApi: LastFMAPI {
    var sessionKey: String?
    
    func getMobileSession(username: String, password: String, completion: @escaping (LastFM.Result<LastFM.GetMobileSessionResponse>) -> ()) {
        completion(.success(LastFM.GetMobileSessionResponse(name: nil, key: nil, subcriber: false)))
    }
    
    var scrobbleCallCount = 0
    var scrobbleSongs: [[PlayedSong]] = []
    var scrobbleResults: [LastFM.Result<LastFM.ScrobbleResponse>] = []
    func scrobble(songs: [PlayedSong], completion: @escaping (LastFM.Result<LastFM.ScrobbleResponse>) -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.scrobbleSongs.append(songs)
            guard self.scrobbleCallCount < self.scrobbleResults.count else {
                return
            }
            let result = self.scrobbleResults[self.scrobbleCallCount]
            self.scrobbleCallCount += 1
            completion(result)
        }
    }
}

class MockDateGenerator: DateGenerator {
    private var date = Date()
    
    func tick(_ seconds: TimeInterval) {
        date = date.addingTimeInterval(seconds)
    }
    
    func rewind(_ seconds: TimeInterval) {
        date = date.addingTimeInterval(-1 * seconds)
    }
    
    func advance(_ seconds: TimeInterval) {
        date = date.addingTimeInterval(seconds)
    }
    
    override func currentDate() -> Date {
        return date
    }
    
    override func date(timeIntervalSince1970: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: timeIntervalSince1970)
    }
}

class MockScrobbleService: ScrobbleService {
    var isLoggedIn: Bool = false
    var currentUserName: String? = nil
    func authenticate(username: String, password: String, completion: @escaping (_ success: Bool) -> ()) {
        
    }
    func signOut() {
        
    }
    func resumeSession() {
        
    }
    func scrobble(songs: [PlayedSong], completion: @escaping ([PlayedSong], Error?) -> ()) {
        
    }
}
