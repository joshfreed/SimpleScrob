//
//  ScrobbleInteractorTests.swift
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

class ScrobbleInteractorTests: XCTestCase {
    // MARK: Subject under test

    var sut: ScrobbleInteractor!
    var worker = MockScrobbleWorker()
    let database = MockDatabase()
    var spy = ScrobblePresentationLogicSpy()
    let df = DateFormatter()

    // MARK: Test lifecycle

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        setupScrobbleInteractor()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: Test setup

    func setupScrobbleInteractor() {
        sut = ScrobbleInteractor(worker: worker)
        sut.presenter = spy
    }

    // MARK: Test doubles

    class MockScrobbleWorker: ScrobbleWorker {
        init() {
            super.init(
                database: MockDatabase(),
                songScanner: MockSongScanner(),
                scrobbleService: MockScrobbleService(),
                connectivity: MockConnectivity()
            )
        }
        
        private var _isLoggedIn = false
        override var isLoggedIn: Bool {
            return _isLoggedIn
        }
        func loggedIn(as username: String?) {
            _isLoggedIn = true
            _username = username
        }
        
        private var _username: String?
        override var currentUserName: String? {
            return _username
        }
        
        var submitCallCount = 0
        var submit_songs: [PlayedSong] = []
        var submit_error: Error?
        override func submit(songs: [PlayedSong], completion: @escaping (Error?) -> ()) {
            submitCallCount += 1
            submit_songs = songs
            completion(submit_error)
        }
        
        var newSongsToScrobble: [PlayedSong] = []
        private var searchForNewSongsToScrobbleWasCalled = false
        override func searchForNewSongsToScrobble(completion: @escaping ([PlayedSong]) -> ()) {
            searchForNewSongsToScrobbleWasCalled = true
            completion(newSongsToScrobble)
        }
        
        func verifySearchedForNewSongsToScrobble() {
            expect(self.searchForNewSongsToScrobbleWasCalled).to(beTrue())
        }
        
        func verifySubmitted(songs: [PlayedSong], callCount: Int = 1) {
            expect(self.submitCallCount).to(equal(callCount))
            expect(self.submit_songs).to(equal(songs))
        }
        func verifySubmitSongs(callCount: Int) {
            expect(self.submitCallCount).to(equal(callCount))
        }
    }
    
    class ScrobblePresentationLogicSpy: ScrobblePresentationLogic {
        func presentFirstTimeView(response: Scrobble.Refresh.Response) {
            
        }
        
        private var presentReadyToScrobbleWasCalled = false
        func presentReadyToScrobble(response: Scrobble.Refresh.Response) {
            presentReadyToScrobbleWasCalled = true
        }
        func verifyPresentReadyToScrobble() {
            expect(self.presentReadyToScrobbleWasCalled).to(beTrue())
        }
        
        func presentAuthorizationPrimer() {
            
        }
        func presentAuthorizationDenied() {
            
        }
        
        private var presentSearchingForNewScrobblesWasCalled = false
        func presentSearchingForNewScrobbles() {
            presentSearchingForNewScrobblesWasCalled = true
        }
        func verifyPresentSearchingForNewScrobbles() {
            expect(self.presentSearchingForNewScrobblesWasCalled).to(beTrue())
        }
        
        private var presentSongsToScrobbleResponse: Scrobble.SearchForNewScrobbles.Response?
        func presentSongsToScrobble(response: Scrobble.SearchForNewScrobbles.Response) {
            presentSongsToScrobbleResponse = response
        }
        func verifyPresentedSongsToScrobble(songs: [PlayedSong]) {
            guard let response = presentSongsToScrobbleResponse else {
                fail("Did not call presentSongsToScrobble")
                return
            }
            
            expect(response.songs).to(equal(songs))
        }
        
        var presentSubmittingToLastFMWasCalled = false
        var presentSubmittingToLastFmCallCount = 0
        func presentSubmittingToLastFM() {
            presentSubmittingToLastFmCallCount += 1
            
        }
        func verifyPresentedSubmittingToLastFM(called callCount: Int = 1) {
            expect(self.presentSubmittingToLastFmCallCount).to(equal(callCount))
        }
        
        var presentScrobblingCompleteCallCount = 0
        var presentScrobblingCompleteResponse: Scrobble.SubmitScrobbles.Response?
        func presentScrobblingComplete(response: Scrobble.SubmitScrobbles.Response) {
            presentScrobblingCompleteCallCount += 1
            presentScrobblingCompleteResponse = response
        }
        func verifyPresentedScrobblingComplete(error: Error?) {
            expect(self.presentScrobblingCompleteCallCount).to(equal(1))
            expect(self.presentScrobblingCompleteResponse).toNot(beNil())
            if let error = error {
                expect(self.presentScrobblingCompleteResponse?.error).toNot(beNil())
//                expect(self.presentScrobblingCompleteResponse?.error).to(matchError(error)) // this should work, but doesn't compile?!
            } else {
                expect(self.presentScrobblingCompleteResponse?.error).to(beNil())
            }
        }
        func verifyPresentedScrobblingComplete(callCount: Int) {
            expect(self.presentScrobblingCompleteCallCount).to(equal(callCount))
        }
        
        var presentScrobbleFailedNotLoggedInCalled = false
        func presentScrobbleFailedNotLoggedIn() {
            presentScrobbleFailedNotLoggedInCalled = true
        }
        func verifyPresentedScrobbleFailedNotLoggedIn() {
            expect(self.presentScrobbleFailedNotLoggedInCalled).to(beTrue())
        }
        
        var presentCurrentUserResponse: Scrobble.GetCurrentUser.Response?
        func presentCurrentUser(response: Scrobble.GetCurrentUser.Response) {
            presentCurrentUserResponse = response
        }
        func verifyPresentedCurrentUser(username: String?) {
            guard let response = presentCurrentUserResponse else {
                fail("presentedCurrentUser was not called")
                return
            }
            
            expect(response.username).to(equal(username))
        }
        func verifyPresentedNilUser() {
            guard let response = presentCurrentUserResponse else {
                fail("presentedCurrentUser was not called")
                return
            }
            
            expect(response.username).to(beNil())
        }
    }

    // MARK: Tests

    func testRefreshHappyPath() {
        // Given
        worker.loggedIn(as: "jfreed")
        worker.newSongsToScrobble = [
            makePlayedSong(persistendId: 1, playedAt: "2017-12-01 14:00:00", artist: "The Dear Hunter", album: "Act II", track: "Red Hands"),
            makePlayedSong(persistendId: 2, playedAt: "2017-12-01 14:00:00", artist: "Beardfish", album: "Sleeping in Traffic", track: "The Hunter")
        ]

        // When
        sut.refresh(request: Scrobble.Refresh.Request())
        
        // Then
        spy.verifyPresentedCurrentUser(username: "jfreed")
        spy.verifyPresentReadyToScrobble()
        spy.verifyPresentSearchingForNewScrobbles()
        worker.verifySearchedForNewSongsToScrobble()
        spy.verifyPresentedSongsToScrobble(songs: worker.newSongsToScrobble)
        spy.verifyPresentedSubmittingToLastFM()
        worker.verifySubmitted(songs: worker.newSongsToScrobble)
        spy.verifyPresentedScrobblingComplete(error: nil)
        expect(self.sut.playedSongs).to(haveCount(0))
    }
    
    func testRefreshNotLoggedIn() {
        // Given
        worker.newSongsToScrobble = [
            makePlayedSong(persistendId: 1, playedAt: "2017-12-01 14:00:00", artist: "The Dear Hunter", album: "Act II", track: "Red Hands"),
            makePlayedSong(persistendId: 2, playedAt: "2017-12-01 14:00:00", artist: "Beardfish", album: "Sleeping in Traffic", track: "The Hunter")
        ]
        worker.submit_error = LastFM.ErrorType.notSignedIn
        
        // When
        sut.refresh(request: Scrobble.Refresh.Request())
        
        // Then
        spy.verifyPresentedNilUser()
        spy.verifyPresentReadyToScrobble()
        spy.verifyPresentSearchingForNewScrobbles()
        worker.verifySearchedForNewSongsToScrobble()
        spy.verifyPresentedSongsToScrobble(songs: worker.newSongsToScrobble)
        spy.verifyPresentedSubmittingToLastFM()
        worker.verifySubmitted(songs: worker.newSongsToScrobble)
        spy.verifyPresentedScrobblingComplete(callCount: 0)
        spy.verifyPresentedScrobbleFailedNotLoggedIn()
        expect(self.sut.playedSongs.count).to(beGreaterThan(0))
    }
    
    func testRefreshWithSubmitError() {
        // Given
        worker.loggedIn(as: "jfreed")
        worker.newSongsToScrobble = [
            makePlayedSong(persistendId: 1, playedAt: "2017-12-01 14:00:00", artist: "The Dear Hunter", album: "Act II", track: "Red Hands"),
            makePlayedSong(persistendId: 2, playedAt: "2017-12-01 14:00:00", artist: "Beardfish", album: "Sleeping in Traffic", track: "The Hunter")
        ]
        worker.submit_error = LastFM.ErrorType.unknown
        
        // When
        sut.refresh(request: Scrobble.Refresh.Request())
        
        // Then
        spy.verifyPresentedCurrentUser(username: "jfreed")
        spy.verifyPresentReadyToScrobble()
        spy.verifyPresentSearchingForNewScrobbles()
        worker.verifySearchedForNewSongsToScrobble()
        spy.verifyPresentedSongsToScrobble(songs: worker.newSongsToScrobble)
        spy.verifyPresentedSubmittingToLastFM()
        worker.verifySubmitted(songs: worker.newSongsToScrobble)
        spy.verifyPresentedScrobblingComplete(error: LastFM.ErrorType.unknown)
        expect(self.spy.presentScrobbleFailedNotLoggedInCalled).to(beFalse())
        expect(self.sut.playedSongs.count).to(beGreaterThan(0))
    }
    
    // submitScrobbles
    
    func test_submitScrobbles_submitsPlayedsongs() {
        // Given
        let request = Scrobble.SubmitScrobbles.Request()
        let songs = [
            makePlayedSong(persistendId: 1, playedAt: "2017-12-01 14:00:00", artist: "The Dear Hunter", album: "Act II", track: "Red Hands"),
            makePlayedSong(persistendId: 2, playedAt: "2017-12-01 14:00:00", artist: "Beardfish", album: "Sleeping in Traffic", track: "The Hunter")
        ]
        sut.playedSongs = songs
        
        // When
        sut.submitScrobbles(request: request)
        
        // Then
        spy.verifyPresentedSubmittingToLastFM(called: 1)
        worker.verifySubmitted(songs: songs)
        spy.verifyPresentedScrobblingComplete(error: nil)
    }
    
    func test_submitScrobbles_doesNotSubmitTwiceInARow() {
        // Given
        let request = Scrobble.SubmitScrobbles.Request()
        sut.playedSongs = [
            makePlayedSong(persistendId: 1, playedAt: "2017-12-01 14:00:00", artist: "The Dear Hunter", album: "Act II", track: "Red Hands"),
            makePlayedSong(persistendId: 2, playedAt: "2017-12-01 14:00:00", artist: "Beardfish", album: "Sleeping in Traffic", track: "The Hunter")
        ]
        sut.submitScrobbles(request: request)
        
        // When
        sut.submitScrobbles(request: request)
        
        // Then
        spy.verifyPresentedSubmittingToLastFM(called: 1)
        worker.verifySubmitSongs(callCount: 1)
        spy.verifyPresentedScrobblingComplete(callCount: 1)
    }
    
    // When a user signs in...
    
    func test_userSignedIn_presentsTheSignedInUserName() {
        // Given
        worker.loggedIn(as: "jfreed")
        
        // When
        sut.userSignedIn()
        
        // Then
        spy.verifyPresentedCurrentUser(username: "jfreed")
    }
    
    func test_userSignedIn_submitsPendingScrobbles() {
        // Given
        let songs = [
            makePlayedSong(persistendId: 1, playedAt: "2017-12-01 14:00:00", artist: "The Dear Hunter", album: "Act II", track: "Red Hands"),
            makePlayedSong(persistendId: 2, playedAt: "2017-12-01 14:00:00", artist: "Beardfish", album: "Sleeping in Traffic", track: "The Hunter")
        ]
        sut.playedSongs = songs

        // When
        sut.userSignedIn()

        // Then
        worker.verifySubmitted(songs: songs)
    }
    
    func test_userSignedIn_doesNotSubmitWhenThereAreNoPendingScrobbles() {
        // Given
        sut.playedSongs = []
        
        // When
        sut.userSignedIn()
        
        // Then
        worker.verifySubmitSongs(callCount: 0)
    }
    
    
    // Helper Funcs
    
    private func makePlayedSong(
        persistendId: MediaItemId,
        playedAt: String,
        artist: String,
        album: String,
        track: String
    ) -> PlayedSong {
        let date = df.date(from: playedAt)
        return PlayedSong(persistentId: persistendId, date: date!, artist: artist, album: album, track: track)
    }
}
