//
//  Mocks.swift
//  SimpleScrobTests
//
//  Created by Josh Freed on 10/5/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
@testable import SimpleScrob

class MockMediaLibrary: MediaLibrary {
    override init() {
        super.init()
    }
}

class MockDatabase: Database {
    func clear() {
        
    }
    
    func findById(_ id: SongID) -> Song? {
        return nil
    }
    
    func insert(_ songs: [Song]) {
        
    }
    
    var saveCallCount = 0
    var savedSongs: [[Song]] = []
    func save(_ songs: [Song]) {
        savedSongs.append(songs)
        saveCallCount += 1
    }
}

class MockSongScanner: SongScanner {
    init() {
        super.init(mediaLibrary: MockMediaLibrary(), database: MockDatabase())
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
    var scrobbleSongs: [[Song]] = []
    var scrobbleResults: [LastFM.Result<LastFM.ScrobbleResponse>] = []
    func scrobble(songs: [Song], completion: @escaping (LastFM.Result<LastFM.ScrobbleResponse>) -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.scrobbleSongs.append(songs)
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
}
