//
//  Mocks.swift
//  SimpleScrobTests
//
//  Created by Josh Freed on 10/5/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
@testable import SimpleScrob

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

class MockDatabase: PlayedSongStore {
    var unscrobbledSongs: [PlayedSong] = []
    func findUnscrobbledSongs(completion: @escaping ([PlayedSong]) -> ()) {
        completion(unscrobbledSongs)
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

    func getRecentScrobbles(skip: Int, limit: Int, completion: @escaping ([PlayedSong]) -> ()) {
        
    }
}

class MockMediaItemStore: MediaItemStore {
    var items: [ScrobbleMediaItem] = []
    
    func findAll(byIds ids: [MediaItemId], completion: @escaping ([ScrobbleMediaItem]) -> ()) {
        let results = items.filter { ids.contains($0.id) }
        completion(results)
    }
    
    var save_savedItems: [ScrobbleMediaItem]?
    func save(mediaItems: [ScrobbleMediaItem], completion: @escaping () -> ()) {
        save_savedItems = mediaItems
        completion()
    }    
}

class MockSongScanner: MediaSource {
    var isInitialized: Bool = false
    
    func initialize(completion: @escaping () -> ()) {
        completion()
    }
    
    func getSongsPlayedSinceLastTime(completion: @escaping ([PlayedSong]) -> ()) {
        completion([])
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
    
    func love(song: PlayedSong, completion: @escaping (LastFM.Result<LastFM.LoveResponse>) -> ()) {
        
    }
}

class MockDateGenerator: DateGenerator {
    private var date = Date()
    
    override var now: Date {
        get {
            return date
        }
        set {
            self.date = newValue
        }
    }
    
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
        return now
    }
    
    override func date(timeIntervalSince1970: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: timeIntervalSince1970)
    }
}

class MockScrobbleService: ScrobbleService {
    var isLoggedIn: Bool = false
    var currentUserName: String? = nil
    func authenticate(username: String, password: String, completion: @escaping (SignInError?) -> ()) {
        
    }
    func signOut() {
        
    }
    func resumeSession() {
        
    }
    
    var scrobble_songs: [PlayedSong] = []
    var scrobble_updatedSongs: [PlayedSong] = []
    var scrobble_error: Error?
    var scrobbleCallCount = 0
    func scrobble(songs: [PlayedSong], completion: @escaping ([PlayedSong], Error?) -> ()) {
        scrobbleCallCount += 1
        scrobble_songs = songs
        completion(scrobble_updatedSongs, scrobble_error)
    }
    
    var loveCallCount = 0
    var lovedSongs: [PlayedSong] = []
    func love(song: PlayedSong, completion: @escaping (Error?) -> ()) {
        loveCallCount += 1
        lovedSongs.append(song)
        completion(nil)
    }
}

class MockConnectivity: Connectivity {
    var isConnectedToInternet: Bool = true
    
    func setConnected() {
        isConnectedToInternet = true
    }
    
    func setNotConnected() {
        isConnectedToInternet = false
    }
}
