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

class MockMediaLibrary: MediaLibrary {
    override init() {
        super.init()
    }
    
    var _items: [MediaItem] = []
    
    override var items: [MediaItem] {
        return _items
    }
    
    override func items(since date: Date?) -> [MediaItem] {
        return _items
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
    init() {
        super.init(mediaLibrary: MockMediaLibrary(), database: MockDatabase(), dateGenerator: MockDateGenerator())
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

class MockSession: Session {
    override init() {
        super.init()
    }
    
    func configureWithSession() {
        start(sessionKey: "123456", username: "flexxo")
    }
    
    func configureWithNoSession() {
        end()
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

class MockSongUpdater: BatchSongUpdater {
    init() {
        super.init(database: MockDatabase())
    }
    
    var markScrobbledCallCount = 0
    var markScrobbled_songs: [[PlayedSong]] = []
    override func markScrobbled(songs: [PlayedSong]) {
        markScrobbled_songs.append(songs)
        markScrobbledCallCount += 1
    }
    
    var markFailedCallCount = 0
    var markFailed_songs: [[PlayedSong]] = []
    var markFailed_errors: [LastFM.ErrorType] = []
    override func markFailed(songs: [PlayedSong], with error: LastFM.ErrorType) {
        markFailed_songs.append(songs)
        markFailed_errors.append(error)
        markFailedCallCount += 1
    }
    
    var markNotScrobbledCallCount = 0
    var markNotScrobbled_songs: [[PlayedSong]] = []
    var markNotScrobbled_errors: [LastFM.ErrorType] = []
    override func markNotScrobbled(songs: [PlayedSong], with error: LastFM.ErrorType) {
        markNotScrobbled_songs.append(songs)
        markNotScrobbled_errors.append(error)
        markNotScrobbledCallCount += 1
    }
}
