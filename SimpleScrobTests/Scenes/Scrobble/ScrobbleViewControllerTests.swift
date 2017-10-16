//
//  ScrobbleViewControllerTests.swift
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

class ScrobbleViewControllerTests: XCTestCase {
    // MARK: Subject under test

    var sut: ScrobbleViewController!
    var window: UIWindow!

    // MARK: Test lifecycle

    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupScrobbleViewController()
    }

    override func tearDown() {
        window = nil
        super.tearDown()
    }

    // MARK: Test setup

    func setupScrobbleViewController() {
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        sut = storyboard.instantiateViewController(withIdentifier:"ScrobbleViewController") as! ScrobbleViewController
    }

    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }

    // MARK: Test doubles

    class ScrobbleBusinessLogicSpy: ScrobbleBusinessLogic {
        var refreshCalled = false
        func refresh(request: Scrobble.Refresh.Request) {
            refreshCalled = true
        }
        
        func requestMediaLibraryAuthorization() {
            
        }
        
        var initializeMusicLibraryCalled = false
        func initializeMusicLibrary(request: Scrobble.InitializeMusicLibrary.Request) {
            initializeMusicLibraryCalled = true
        }
        
        func searchForNewScrobbles(request: Scrobble.SearchForNewScrobbles.Request) {
            
        }
        
        func submitScrobbles(request: Scrobble.SubmitScrobbles.Request) {
            
        }
        
        func getCurrentUser() {
            
        }
        
        func signOut(request: Scrobble.SignOut.Request) {
            
        }
    }

    // MARK: Tests

    func testShouldDoSomethingWhenViewIsLoaded() {
        // Given
        let spy = ScrobbleBusinessLogicSpy()
        sut.interactor = spy

        // When
        loadView()

        // Then
        XCTAssertTrue(spy.refreshCalled, "viewDidLoad() should ask the interactor to do something")
    }

    func test_displayAuthorizationPrimer() {
        // When
        loadView()
        sut.displayAuthorizationPrimer()
        
        // Then
        expect(self.sut.statusLabel.isHidden).to(beFalse())
        expect(self.sut.statusLabel.text).to(equal("SimpleScrob needs access to your music library to track the songs you play."))
        expect(self.sut.requestAuthorizationButton.isHidden).to(beFalse())
        expect(self.sut.viewScrobblesButton.isHidden).to(beTrue())
        expect(self.sut.viewScrobblesHitAreaButton.isHidden).to(beTrue())
    }
    
    func test_displayAuthorized_firstTime() {
        // Given
        let spy = ScrobbleBusinessLogicSpy()
        sut.interactor = spy
        let viewModel = Scrobble.Refresh.ViewModel(firstTime: true)
        loadView()
        sut.viewScrobblesButton.isHidden = true
        sut.viewScrobblesHitAreaButton.isHidden = true
        
        // When
        sut.displayAuthorized(viewModel: viewModel)
        
        // Then
        expect(self.sut.requestAuthorizationButton.isHidden).to(beTrue())
        expect(self.sut.statusLabel.text).to(equal(""))
        expect(self.sut.viewScrobblesButton.isHidden).to(beFalse())
        expect(self.sut.viewScrobblesHitAreaButton.isHidden).to(beFalse())
        expect(spy.initializeMusicLibraryCalled).to(beTrue())
    }
    
    func testDisplayCurrentUser() {
        // Given
        let viewModel = Scrobble.GetCurrentUser.ViewModel(username: "Brad")

        // When
        loadView()
        sut.displayCurrentUser(viewModel: viewModel)

        // Then
        expect(self.sut.currentUserButton.isHidden).to(beFalse())
        expect(self.sut.isLoggedIn).to(beTrue())
    }
    
    func testDisplayCurrentUser_hides_user_on_logout() {
        // Given
        loadView()
        sut.isLoggedIn = true
        sut.currentUserButton.isHidden = false
        sut.signInButton.isHidden = true
        let viewModel = Scrobble.GetCurrentUser.ViewModel(username: nil)
        
        // When        
        sut.displayCurrentUser(viewModel: viewModel)
        
        // Then
        expect(self.sut.currentUserButton.isHidden).to(beTrue())
        expect(self.sut.isLoggedIn).to(beFalse())
        expect(self.sut.signInButton.isHidden).to(beFalse())
    }
    
    func testDisplaySubmittingToLastFM() {
        // Given
        
        
        // When
        loadView()
        sut.errorLabel.isHidden = false
        sut.retryButton.isHidden = false
        sut.displaySubmittingToLastFM()
        
        // Then
        expect(self.sut.statusLabel.isHidden).to(beFalse())
        expect(self.sut.statusLabel.text).to(equal("Submitting to last.fm..."))
        expect(self.sut.activityIndicator.isAnimating).to(beTrue())
        expect(self.sut.activityIndicator.isHidden).to(beFalse())
        expect(self.sut.errorLabel.isHidden).to(beTrue())
        expect(self.sut.retryButton.isHidden).to(beTrue())
    }
    
    func testDisplayScrobblingComplete() {
        // Given
        let viewModel = Scrobble.SubmitScrobbles.ViewModel(error: nil)
        
        // When
        loadView()
        sut.displayScrobblingComplete(viewModel: viewModel)
        
        // Then
        expect(self.sut.statusLabel.isHidden).to(beFalse())
        expect(self.sut.doneLabel.isHidden).to(beFalse())
        expect(self.sut.activityIndicator.isAnimating).to(beFalse())
        expect(self.sut.activityIndicator.isHidden).to(beTrue())
        expect(self.sut.errorLabel.isHidden).to(beTrue())
        expect(self.sut.retryButton.isHidden).to(beTrue())
    }
    
    func testDisplayScrobblingComplete_withErrorMessage() {
        // Given
        let viewModel = Scrobble.SubmitScrobbles.ViewModel(error: "An error has occurred.")
        
        // When
        loadView()
        sut.displayScrobblingComplete(viewModel: viewModel)
        
        // Then
        expect(self.sut.activityIndicator.isAnimating).to(beFalse())
        expect(self.sut.activityIndicator.isHidden).to(beTrue())
        expect(self.sut.doneLabel.isHidden).to(beTrue())
        expect(self.sut.errorLabel.isHidden).to(beFalse())
        expect(self.sut.retryButton.isHidden).to(beFalse())
        expect(self.sut.errorLabel.text).to(equal(viewModel.error))
    }
}
