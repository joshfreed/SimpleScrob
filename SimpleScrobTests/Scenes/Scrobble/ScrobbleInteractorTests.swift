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

class ScrobbleInteractorTests: XCTestCase {
    // MARK: Subject under test

    var sut: ScrobbleInteractor!
    let mediaLibrary = MockMediaLibrary()
    let worker = MockScrobbleWorker()
    let database = MockDatabase()
    let songScanner = MockSongScanner()

    // MARK: Test lifecycle

    override func setUp() {
        super.setUp()
        setupScrobbleInteractor()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: Test setup

    func setupScrobbleInteractor() {
        sut = ScrobbleInteractor(
            mediaLibrary: mediaLibrary,
            worker: worker,
            database: database,
            songScanner: songScanner
        )
    }

    // MARK: Test doubles

    class MockScrobbleWorker: ScrobbleWorker {
        init() {
            super.init(api: MockLastFMApi(), database: MockDatabase(), session: MockSession())
        }
        
        override func submit(songs: [Song], completion: @escaping (Error?) -> ()) {
            completion(nil)
        }
    }
    
    class ScrobblePresentationLogicSpy: ScrobblePresentationLogic {
        func presentAuthorized(response: Scrobble.Refresh.Response) {
            
        }
        
        func presentAuthorizationPrimer() {
            
        }
        
        func presentAuthorizationDenied() {
            
        }
        
        func presentScanningMusicLibrary() {
            
        }
        
        func presentLibraryScanComplete(response: Scrobble.InitializeMusicLibrary.Response) {
            
        }
        
        func presentSearchingForNewScrobbles() {
            
        }
        
        func presentSongsToScrobble(response: Scrobble.SearchForNewScrobbles.Response) {
            
        }
        
        func presentSubmittingToLastFM() {
            
        }
        
        func presentCurrentUser(response: Scrobble.GetCurrentUser.Response) {
        
        }
        
        var presentScrobblingCompleteCalled = false
        func presentScrobblingComplete(response: Scrobble.SubmitScrobbles.Response) {
            presentScrobblingCompleteCalled = true
        }
    }

    // MARK: Tests

//    func testSubmitScrobbles() {
//        // Given
//        let spy = ScrobblePresentationLogicSpy()
//        sut.presenter = spy
//        let request = Scrobble.SubmitScrobbles.Request()        
//
//        // When
//        sut.submitScrobbles(request: request)
//
//        // Then
//        XCTAssertTrue(spy.presentScrobblingCompleteCalled, "doSomething(request:) should ask the presenter to format the result")
//    }
}
