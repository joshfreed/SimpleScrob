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
    
    // MARK: Song params
    
    func testSongParams() {
        let song = PlayedSongBuilder
            .aSong()
            .playedAt("2018-03-28 14:15:16")
            .with(artist: "Beardfish")
            .with(album: "Sleeping in Traffic")
            .with(track: "Sunrise")
            .with(albumArtist: "Something Something")
            .build()
        var params: [String: String] = [:]
        
        sut.addSongParams(params: &params, song: song, index: 0)
        
        expect(params["artist[0]"]).to(equal("Beardfish"))
        expect(params["album[0]"]).to(equal("Sleeping in Traffic"))
        expect(params["track[0]"]).to(equal("Sunrise"))
        expect(params["albumArtist[0]"]).to(equal("Something Something"))
        expect(params["timestamp[0]"]).to(equal(song.scrobbleTimestamp))
    }
    
    func testSongParams_doesNotIncludeAlbumArtistWhenNil() {
        let song = PlayedSongBuilder
            .aSong()
            .playedAt("2018-03-28 14:15:16")
            .with(artist: "Beardfish")
            .with(album: "Sleeping in Traffic")
            .with(track: "Sunrise")
            .with(albumArtist: nil)
            .build()
        var params: [String: String] = [:]
        
        sut.addSongParams(params: &params, song: song, index: 0)
        
        expect(params.keys.contains("albumArtist[0]")).to(beFalse())
        expect(params["artist[0]"]).to(equal("Beardfish"))
        expect(params["album[0]"]).to(equal("Sleeping in Traffic"))
        expect(params["track[0]"]).to(equal("Sunrise"))
        expect(params["timestamp[0]"]).to(equal(song.scrobbleTimestamp))
    }

    // MARK: scrobble
    
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
                        "album": ["corrected": 0, "#text": "Sleeping in Traffic"],
                        "ignoredMessage": ["#text": "", "code": 0],
                        "timestamp": 1507156068
                    ]
                ]
            ]
        ]
        engine.post_result = .success(json)
        
        var response: LastFM.ScrobbleResponse?
        let songs = [PlayedSongBuilder.aSong().build()]
        sut.scrobble(songs: songs) { result in
            if case let .success(_response) = result {
                response = _response
            }
        }
        
        expect(response).toNot(beNil())
        expect(response?.accepted).to(haveCount(1))
        expect(response?.ignored).to(haveCount(0))
        expect(response?.accepted[0].track).to(equal("Sunrise"))
        expect(response?.accepted[0].artist).to(equal("Beardfish"))
        expect(response?.accepted[0].album).to(equal("Sleeping in Traffic"))
        expect(response?.accepted[0].timestamp).to(equal(1507156068))
    }
    
    func testScrobbleAddsIgnoredTracksToTheIgnoredArray() {
        // Given
        let json: [String: Any] = [
            "scrobbles": [
                "@attr": [
                    "accepted": 2,
                    "ignored": 1,
                ],
                "scrobble": [
                    [
                        "track": ["corrected": 0, "#text": "Sunrise"],
                        "artist": ["corrected": 0, "#text": "Beardfish"],
                        "ignoredMessage": ["#text": "", "code": 0],
                        "timestamp": 1507156068
                    ],
                    [
                        "track": ["corrected": 0, "#text": "Afternoon Conversation"],
                        "artist": ["corrected": 0, "#text": "Beardfish"],
                        "ignoredMessage": ["#text": "Ignored this track", "code": 1],
                        "timestamp": 1507156368
                    ],
                    [
                        "track": ["corrected": 0, "#text": "And Never Know"],
                        "artist": ["corrected": 0, "#text": "Beardfish"],
                        "ignoredMessage": ["#text": "", "code": 0],
                        "timestamp": 1507156968
                    ]
                ]
            ]
        ]
        engine.post_result = .success(json)
        let songs = [PlayedSongBuilder.aSong().build()]
        
        // When
        var response: LastFM.ScrobbleResponse?
        sut.scrobble(songs: songs) { result in
            if case let .success(_response) = result {
                response = _response
            }
        }
        
        // Then
        expect(response).toNot(beNil())
        expect(response?.accepted).to(haveCount(2))
        expect(response?.ignored).to(haveCount(1))
        expect(response?.accepted[0].track).to(equal("Sunrise"))
        expect(response?.accepted[1].track).to(equal("And Never Know"))
        expect(response?.ignored[0].track).to(equal("Afternoon Conversation"))
        expect(response?.ignored[0].ignoredCode).to(equal(1))
        expect(response?.ignored[0].ignoredMessage).to(equal("Ignored this track"))
    }
    
    // MARK: love
    
    func testLoveTrack() {
        // Given
        sut.sessionKey = "MySessionKey"
        let json: [String: Any] = [:]
        engine.post_result = .success(json)
        let songToLove = PlayedSongBuilder
            .aSong()
            .with(artist: "The Dear Hunter")
            .with(track: "A Night on the Town")
            .build()
        
        // When
        var response: LastFM.LoveResponse?
        sut.love(song: songToLove) { result in
            if case let .success(_response) = result {
                response = _response
            }
        }
        
        // Then
        expect(self.engine.post_method).to(equal("track.love"))
        
        expect(self.engine.post_params).toNot(beNil())
        let params = engine.post_params!
        expect(params["sk"]).to(equal("MySessionKey"))
        expect(params["track"]).to(equal("A Night on the Town"))
        expect(params["artist"]).to(equal("The Dear Hunter"))
        
        expect(response).toNot(beNil())
    }
    
    func testLoveTrackWithError() {
        // Given
        sut.sessionKey = "MySessionKey"
        let songToLove = PlayedSongBuilder
            .aSong()
            .with(artist: "The Dear Hunter")
            .with(track: "A Night on the Town")
            .build()
        let expectedError = LastFM.ErrorType.error(code: 11, message: "Some Error")
        engine.post_result = .failure(expectedError)
        
        // When
        var error: Error?
        sut.love(song: songToLove) { result in
            if case let .failure(_error) = result {
                error = _error
            }
        }
        
        // Then
        expect(error).to(matchError(expectedError))
    }
}
