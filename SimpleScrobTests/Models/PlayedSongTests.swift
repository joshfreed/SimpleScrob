//
//  PlayedSongTests.swift
//  SimpleScrobTests
//
//  Created by Josh Freed on 10/6/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import XCTest
@testable import SimpleScrob
import Nimble

class PlayedSongTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIdEquality_same_date_and_time_but_different_instances_are_still_equal() {
        let timestamp = Date().timeIntervalSince1970
        let date1 = Date(timeIntervalSince1970: timestamp)
        let date2 = Date(timeIntervalSince1970: timestamp)
        
        let id1 = PlayedSongId(persistentId: 1, date: date1)
        let id2 = PlayedSongId(persistentId: 1, date: date2)
        
        expect(id1).to(equal(id2))
    }
    
    func testIdEquality_same_id_with_different_dates_are_not_equal() {
        let timestamp = Date().timeIntervalSince1970
        let date1 = Date(timeIntervalSince1970: timestamp)
        let date2 = Date(timeIntervalSince1970: timestamp + 1)
        
        let id1 = PlayedSongId(persistentId: 1, date: date1)
        let id2 = PlayedSongId(persistentId: 1, date: date2)
        
        expect(id1).toNot(equal(id2))
    }
}
