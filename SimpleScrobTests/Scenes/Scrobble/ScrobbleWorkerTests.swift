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
            scrobbleService: scrobbleService
        )
    }

    // MARK: Test doubles

    // MARK: Tests

    // MARK: Helper Funcs

}
