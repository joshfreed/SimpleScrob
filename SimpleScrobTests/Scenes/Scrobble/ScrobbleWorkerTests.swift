//
//  ScrobbleWorkerTests.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/5/17.
//  Copyright (c) 2017 Josh Freed. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import SimpleScrob
import XCTest
import Nimble

class ScrobbleWorkerTests: XCTestCase {
    // MARK: Subject under test

    var sut: ScrobbleWorker!
    let database = MockDatabase()
    let songScanner = MockSongScanner()
    let scrobbleService = MockScrobbleService()
    let connectivity = MockConnectivity()

    // MARK: Test lifecycle

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        setupScrobbleWorker()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: Test setup

    func setupScrobbleWorker() {
        sut = ScrobbleWorker(
            database: database,
            songScanner: songScanner,
            scrobbleService: scrobbleService,
            connectivity: connectivity
        )
    }

    // MARK: Test doubles

    // MARK: Tests
    
    func test_submit_sends_to_scrobble_service_and_saves_to_db() {
        let originalSongs: [PlayedSong] = [
            PlayedSongBuilder.aSong().build(),
            PlayedSongBuilder.aSong().build(),
            PlayedSongBuilder.aSong().build()
        ]
        let updatedSongs: [PlayedSong] = [
            PlayedSongBuilder.aSong().with(status: .scrobbled).build(),
            PlayedSongBuilder.aSong().with(status: .scrobbled).build(),
            PlayedSongBuilder.aSong().with(status: .scrobbled).build()
        ]
        scrobbleService.scrobble_updatedSongs = updatedSongs
        scrobbleService.scrobble_error = nil
        var responseError: Error?
        let completionExpectation = expectation(description: "Submission completes")
        
        sut.submit(songs: originalSongs) { error in
            responseError = error
            completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
        expect(self.database.saveCallCount).to(equal(1))
        expect(self.database.savedSongs[0]).to(equal(updatedSongs))
        expect(responseError).to(beNil())
    }
    
    func test_submit_mark_songs_not_submitted_when_there_is_no_internet() {
        connectivity.setNotConnected()
        let originalSongs: [PlayedSong] = [
            PlayedSongBuilder.aSong().build(),
            PlayedSongBuilder.aSong().build(),
            PlayedSongBuilder.aSong().build()
        ]
        var responseError: Error?
        let completionExpectation = expectation(description: "Submission completes")
        
        sut.submit(songs: originalSongs) { error in
            responseError = error
            completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
        expect(responseError).to(matchError(ScrobbleError.notConnected))
        expect(self.scrobbleService.scrobbleCallCount).to(equal(0))
        expect(self.database.saveCallCount).to(equal(1))
        expect(self.database.savedSongs[0]).to(allPass { $0?.status == .notScrobbled })
        expect(self.database.savedSongs[0]).to(allPass { $0?.reason == ScrobbleError.notConnected.description })
    }

    // MARK: Helper Funcs

}
