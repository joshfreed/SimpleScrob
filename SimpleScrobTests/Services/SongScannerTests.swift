//
//  SongScanner.swift
//  SimpleScrobTests
//
//  Created by Josh Freed on 10/8/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import XCTest
@testable import SimpleScrob
import Nimble

class SongScannerTests: XCTestCase {
    var sut: SongScanner!
    let mediaLibrary = MockMediaLibrary()
    let database = MockDatabase()
    let dateGenerator = MockDateGenerator()
    let oneDay: TimeInterval = 3600 * 24
    
    override func setUp() {
        super.setUp()

        mediaLibrary._items = []
        
        sut = SongScanner(
            mediaLibrary: mediaLibrary,
            database: database,
            dateGenerator: dateGenerator
        )
        sut.reset()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScrobbleSearchDate_startsNil() {
        expect(self.sut.scrobbleSearchDate).to(beNil())
    }
    
    func testScrobbleSearchDate_set_to_the_date_first_initialized() {
        let expected = dateGenerator.currentDate()
        
        sut.initializeSongDatabase()
        
        expect(self.sut.scrobbleSearchDate).to(beCloseTo(expected))
    }
    
    func testScrobbleSearchDate_set_to_date_last_searched() {
        dateGenerator.rewind(oneDay)
        sut.initializeSongDatabase()
        dateGenerator.advance(oneDay)
        let _ = sut.searchForNewScrobbles()
        let expected = dateGenerator.currentDate().addingTimeInterval(-3600)
        
        expect(self.sut.scrobbleSearchDate).to(beCloseTo(expected))
    }
    
    func testIsInitialized_returns_false_at_first() {
        expect(self.sut.isInitialized).to(beFalse())
    }
    
    func testIsInitialize_true_after_initializing_the_library() {
        sut.initializeSongDatabase()
        expect(self.sut.isInitialized).to(beTrue())
    }
}
