//
//  LastFmScrobblingService.swift
//  SimpleScrobTests
//
//  Created by Josh Freed on 11/19/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import XCTest
@testable import SimpleScrob
import Nimble
import MediaPlayer

class LastFmScrobbleServiceTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: TestableLastFmScrobbleService!
    let api = MockLastFMApi()
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        sut = TestableLastFmScrobbleService(api: api)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test doubles
    
    class TestableLastFmScrobbleService: LastFmScrobbleService {
        var _isLoggedIn = false
        override var isLoggedIn: Bool {
            return _isLoggedIn
        }
        func configureWithSession() {
            _isLoggedIn = true
        }
        func configureWithNoSession() {
            _isLoggedIn = false
        }
    }
    
    // MARK: Tests
    
    func testSubmitLessThan50Songs() {
        // Given
        sut.configureWithSession()
        let songs = [
            PlayedSong(persistentId: 1, date: Date(), artist: "Beardfish", album: "Sleeping in Traffic", track: "Sunrise"),
            PlayedSong(persistentId: 2, date: Date(), artist: "Beardfish", album: "Sleeping in Traffic", track: "Afternoon Conversation")
        ]
        let response = LastFM.ScrobbleResponse(accepted: [], ignored: [])
        api.scrobbleResults.append(.success(response))
        var completionCalled = false
        var completionSongs: [PlayedSong] = []
        var completionError: Error?
        let completionExpectation = expectation(description: "Submission completes")
        
        // When
        sut.scrobble(songs: songs) { (playedSongs, error) in
            completionCalled = true
            completionSongs = playedSongs
            completionError = error
            completionExpectation.fulfill()
        }
        
        // Then
        wait(for: [completionExpectation], timeout: 3)
        expect(self.api.scrobbleCallCount).to(equal(1))
        expect(self.api.scrobbleSongs[0]).to(equal(songs))
        expect(completionCalled).to(beTrue())
        expect(completionError).to(beNil())
        expect(completionSongs).to(haveCount(songs.count))
        expect(completionSongs).to(allPass{ $0?.status == .scrobbled })
    }
    
    func testSubmitMoreThan50Songs() {
        // Given
        sut.configureWithSession()
        let batch1 = makeSongs(count: 50)
        let batch2 = makeSongs(count: 50)
        let batch3 = makeSongs(count: 26)
        var allSongs: [PlayedSong] = []
        allSongs.append(contentsOf: batch1)
        allSongs.append(contentsOf: batch2)
        allSongs.append(contentsOf: batch3)
        api.scrobbleResults.append(.success(LastFM.ScrobbleResponse(accepted: [], ignored: [])))
        api.scrobbleResults.append(.success(LastFM.ScrobbleResponse(accepted: [], ignored: [])))
        api.scrobbleResults.append(.success(LastFM.ScrobbleResponse(accepted: [], ignored: [])))
        var completionCalled = false
        var completionSongs: [PlayedSong] = []
        var completionError: Error?
        let completionExpectation = expectation(description: "Submission completes")
        
        // When
        sut.scrobble(songs: allSongs) { (playedSongs, error) in
            completionCalled = true
            completionSongs = playedSongs
            completionError = error
            completionExpectation.fulfill()
        }
        
        // Then
        wait(for: [completionExpectation], timeout: 3)
        expect(self.api.scrobbleCallCount).to(equal(3))
        expect(self.api.scrobbleSongs[0]).to(equal(batch1))
        expect(self.api.scrobbleSongs[1]).to(equal(batch2))
        expect(self.api.scrobbleSongs[2]).to(equal(batch3))
        expect(completionCalled).to(beTrue())
        expect(completionError).to(beNil())
        expect(completionSongs).to(haveCount(allSongs.count))
        expect(completionSongs).to(allPass{ $0?.status == .scrobbled })
    }
    
    func testSubmitHadErrors() {
        // Given
        sut.configureWithSession()
        let batch1 = makeSongs(count: 50)
        let batch2 = makeSongs(count: 50)
        let batch3 = makeSongs(count: 26)
        var allSongs: [PlayedSong] = []
        allSongs.append(contentsOf: batch1)
        allSongs.append(contentsOf: batch2)
        allSongs.append(contentsOf: batch3)
        api.scrobbleResults.append(.success(LastFM.ScrobbleResponse(accepted: [], ignored: [])))
        api.scrobbleResults.append(.failure(.error(code: 11, message: "Whatever")))
        api.scrobbleResults.append(.success(LastFM.ScrobbleResponse(accepted: [], ignored: [])))
        var completionCalled = false
        var completionSongs: [PlayedSong] = []
        var completionError: Error?
        let completionExpectation = expectation(description: "Submission completes")
        
        // When
        sut.scrobble(songs: allSongs) { (playedSongs, error) in
            completionCalled = true
            completionSongs = playedSongs
            completionError = error
            completionExpectation.fulfill()
        }
        
        // Then
        wait(for: [completionExpectation], timeout: 3)
        expect(completionCalled).to(beTrue())
        expect(completionError).to(matchError(LastFM.ErrorType.error(code: 11, message: "Whatever")))
        expect(self.api.scrobbleCallCount).to(equal(2))
        expect(completionSongs).to(haveCount(allSongs.count))
        expect(completionSongs[0..<50]).to(allPass{ $0?.status == .scrobbled })
        expect(completionSongs[50..<100]).to(allPass{ $0?.status == .failed })
        expect(completionSongs[100..<126]).to(allPass{ $0?.status == .notScrobbled })
    }
    
    func test_submit_not_logged_in() {
        // Given
        sut.configureWithNoSession()
        let songs = makeSongs(count: 33)
        var completionCalled = false
        var completionSongs: [PlayedSong] = []
        var completionError: Error?
        let completionExpectation = expectation(description: "Submission completes")
        
        // When
        sut.scrobble(songs: songs) { (playedSongs, error) in
            completionCalled = true
            completionSongs = playedSongs
            completionError = error
            completionExpectation.fulfill()
        }
        
        // Then
        wait(for: [completionExpectation], timeout: 3)
        expect(completionCalled).to(beTrue())
        expect(completionError).to(matchError(LastFM.ErrorType.notSignedIn))
        expect(self.api.scrobbleCallCount).to(equal(0))
        expect(completionSongs).to(allPass { $0?.status == .notScrobbled })
    }
    
    // MARK: Helper Funcs
    
    private var _songId: MPMediaEntityPersistentID = 1
    func makeSongs(count: Int) -> [PlayedSong] {
        var songs: [PlayedSong] = []
        for _ in 0..<count {
            let playedSong = PlayedSong(persistentId: _songId, date: Date(), artist: "Artist\(_songId)", album: "Album_\(_songId)", track: "Track\(_songId)")
            songs.append(playedSong)
            _songId += 1
        }
        return songs
    }
}
