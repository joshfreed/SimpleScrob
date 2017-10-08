//
//  LastFM_ApiTests.swift
//  SimpleScrobTests
//
//  Created by Josh Freed on 10/4/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import XCTest
@testable import SimpleScrob
import Nimble

class LastFM_ApiTests: XCTestCase {
    var sut: LastFM.API!
    var engine = MockEngine()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        sut = LastFM.API(engine: engine)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    class MockEngine: LastFM.RestEngine {
        init() {
            super.init(apiKey: "", secret: "")
        }
        
        var post_method: String?
        var post_params: [String: String]?
        var post_result: LastFM.Result<[String: Any]>?
        override func post(method: String, params: [String: String], completion: @escaping (LastFM.Result<[String: Any]>) -> ()) {
            post_method = method
            post_params = params
            if let result = post_result {
                completion(result)
            }
        }
    }
    
    func testSongParams() {
        var cmp = DateComponents()
        cmp.hour = -1
        let calendar = Calendar.current
        let date = Date()
        let lastPlayedDate = calendar.date(byAdding: cmp, to: date)!
        
        let songs = [
            PlayedSong(persistentId: 1, date: lastPlayedDate, artist: "Beardfish", album: "Sleeping in Traffic", track: "Sunrise")
        ]
        
        sut.scrobble(songs: songs) { _ in }
        
        expect(self.engine.post_params).toNot(beNil())
        let params = engine.post_params!
        expect(params["artist[0]"]).to(equal("Beardfish"))
        expect(params["album[0]"]).to(equal("Sleeping in Traffic"))
        expect(params["track[0]"]).to(equal("Sunrise"))
        expect(params["timestamp[0]"]).to(equal(songs[0].scrobbleTimestamp))
    }
    
    func testTranslatesJSONToResponseObject() {
        let json: [String: Any] = [
            "scrobbles": [
                "@attr": [
                    "accepted": 1,
                    "ignored": 0,
                ],
                "scrobble": [
                    [
                        "track": ["corrected": 0, "#text": "Sunrise"],
                        "artist": ["corrected": 0, "#text": "Beardfish"],
                        "ignoredMessage": ["#text": "", "code": 0],
                        "timestamp": 1507156068
                    ]
                ]
            ]
        ]
        engine.post_result = .success(json)
        
        var response: LastFM.ScrobbleResponse?
        let songs = [PlayedSong(persistentId: 1, date: Date(), artist: "Beardfish", album: "Sleeping in Traffic", track: "Sunrise")]
        sut.scrobble(songs: songs) { result in
            if case let .success(_response) = result {
                response = _response
            }
        }
        
        expect(response).toNot(beNil())
        expect(response?.accepted).to(haveCount(1))
        expect(response?.ignored).to(haveCount(0))
        expect(response?.accepted[0].track).to(equal("Sunrise"))
    }
}
