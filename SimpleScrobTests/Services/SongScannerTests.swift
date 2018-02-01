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
import JFLib

class SongScannerTests: XCTestCase {
    var sut: SongScanner!
    let deviceMediaLibrary = MockMediaLibrary()
    let cachedMediaItemStore = MockMediaItemStore()
    let dateGenerator = MockDateGenerator()
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        deviceMediaLibrary._items = []
        
        sut = SongScanner(
            mediaLibrary: deviceMediaLibrary,
            dateGenerator: dateGenerator,
            mediaItemStore: cachedMediaItemStore
        )
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsInitialized_returns_false_at_first() {
        UserDefaults.standard.removeObject(forKey: "musicLibraryIsInitialized")
        expect(self.sut.isInitialized).to(beFalse())
    }
    
    func testIsInitialize_true_after_initializing_the_library() {
        sut.initialize(completion: {})
        expect(self.sut.isInitialized).to(beTrue())
    }
    
    //
    // getSongsPlayedSinceLastTime
    //
    
    func test_getSongsPlayedSinceLastTime() {
        // Given
        deviceMediaLibrary._items = [
            makeMediaItem(id: 1, lastPlayedDate: "2018-01-29 15:16:00", playCount: 2, artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        ]
        cachedMediaItemStore.items = [
            makeCachedItem(id: 1, playCount: 1, lastPlayedDate: "2018-01-28 10:00:00")
        ]
        let completionExpectation = expectation(description: "searchForNewScrobbles")
        
        // When
        var playedSongs: [PlayedSong] = []
        sut.getSongsPlayedSinceLastTime() { _playedSongs in
            playedSongs = _playedSongs
            completionExpectation.fulfill()
        }
        
        // Then
        wait(for: [completionExpectation], timeout: 3)
        expect(playedSongs).to(haveCount(1))
        verifyPlayedSong(playedSongs[0], id: 1, date: "2018-01-29 15:16:00", artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        expect(self.cachedMediaItemStore.save_savedItems).toNot(beNil())
        expect(self.cachedMediaItemStore.save_savedItems).to(haveCount(1))
        expect(self.cachedMediaItemStore.save_savedItems?[0].id).to(equal(1))
        expect(self.cachedMediaItemStore.save_savedItems?[0].playCount).to(equal(2))
        expect(self.cachedMediaItemStore.save_savedItems?[0].lastPlayedDate).to(equal(Date.makeDate(from: "2018-01-29 15:16:00")))
    }
    
    func test_getSongsPlayedSinceLastTime_updatesCacheForEntireMediaLibrary() {
        deviceMediaLibrary._items = [
            makeMediaItem(id: 1, lastPlayedDate: "2018-01-29 15:16:00", playCount: 2, artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down"),
            makeMediaItem(id: 2, lastPlayedDate: "2018-01-29 15:20:00", playCount: 1, artist: "The Dear Hunter", album: "Migrant", title: "Whisper"),
            makeMediaItem(id: 3, lastPlayedDate: "2018-01-29 15:24:00", playCount: 3, artist: "The Dear Hunter", album: "Migrant", title: "Shame"),
            makeMediaItem(id: 4, lastPlayedDate: nil, playCount: 0, artist: "The Dear Hunter", album: "Migrant", title: "An Escape")
        ]
        cachedMediaItemStore.items = [
            makeCachedItem(id: 1, playCount: 1, lastPlayedDate: "2018-01-28 10:00:00"),
            makeCachedItem(id: 2, playCount: 1, lastPlayedDate: "2018-01-28 10:00:00"),
            makeCachedItem(id: 3, playCount: 2, lastPlayedDate: "2018-01-28 10:00:00")
        ]
        let completionExpectation = expectation(description: "searchForNewScrobbles")
        
        // When
        sut.getSongsPlayedSinceLastTime() { _ in
            completionExpectation.fulfill()
        }
        
        // Then
        wait(for: [completionExpectation], timeout: 3)
        expect(self.cachedMediaItemStore.save_savedItems).to(haveCount(4))
        expect(self.cachedMediaItemStore.save_savedItems).to(allPass({ [1, 2, 3, 4].contains($0!.id) }))
    }
    
    //
    // makeSongsToScrobble
    //
    
    func test_makeSongsToScrobble_returnsSongIfItDoesNotExistInMediaItemStore() {
        // Given
        let cachedMediaItems: [ScrobbleMediaItem] = []
        let currentMediaItems = [
            makeMediaItem(id: 1, lastPlayedDate: "2018-01-29 15:16:00", playCount: 1, artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        ]        
        
        // When
        let actual = sut.makeSongsToScrobble(currentMediaItems: currentMediaItems, cachedMediaItems: cachedMediaItems)
        
        // Then
        expect(actual).to(haveCount(1))
        verifyPlayedSong(actual[0], id: 1, date: "2018-01-29 15:16:00", artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
    }
    
    func test_makeSongsToScrobble_scrobblesSongIfItHasBeenPlayedSinceLastSeen() {
        // Given
        let cachedMediaItems = [
            makeCachedItem(id: 1, playCount: 1, lastPlayedDate: "2018-01-28 10:00:00")
        ]
        let currentMediaItems = [
            makeMediaItem(id: 1, lastPlayedDate: "2018-01-29 15:16:00", playCount: 2, artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        ]
        
        // When
        let actual = sut.makeSongsToScrobble(currentMediaItems: currentMediaItems, cachedMediaItems: cachedMediaItems)
        
        // Then
        expect(actual).to(haveCount(1))
        verifyPlayedSong(actual[0], id: 1, date: "2018-01-29 15:16:00", artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
    }
    
    func test_makeSongsToScrobble_doesNotIncludeTheSongIfItHasNotBeenPlayedSinceLastTime() {
        // Given
        let cachedMediaItems = [
            makeCachedItem(id: 1, playCount: 1, lastPlayedDate: "2018-01-29 15:16:00")
        ]
        let currentMediaItems = [
            makeMediaItem(id: 1, lastPlayedDate: "2018-01-29 15:16:00", playCount: 1, artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        ]
        
        // When
        let actual = sut.makeSongsToScrobble(currentMediaItems: currentMediaItems, cachedMediaItems: cachedMediaItems)
        
        // Then
        expect(actual).to(haveCount(0))
    }
    
    //
    // makeSongToScrobble
    //
    
    func test_makeSongToScrobble_scrobblesTheSongIfItIsNewToTheMediaLibrary() {
        // Given
        let currentItem = makeMediaItem(id: 1, lastPlayedDate: "2018-01-29 15:16:00", playCount: 1, artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        
        // When
        let actual = sut.makeSongToScrobble(currentItem: currentItem, cachedItem: nil)
        
        // Then
        expect(actual).to(haveCount(1))
        verifyPlayedSong(actual[0],
            id: 1,
            date: "2018-01-29 15:16:00",
            artist: "The Dear Hunter",
            album: "Migrant",
            title: "Bring You Down"
        )
    }
    
    func test_makeSongToScrobble_scrobblesTheSongIfThePlayCountIsHigherThanTheLastTime() {
        // Given
        let currentItem = makeMediaItem(id: 1, lastPlayedDate: "2018-01-29 15:16:00", playCount: 2, artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        let cachedItem = makeCachedItem(id: 1, playCount: 1, lastPlayedDate: "2018-01-28 10:00:00")
        
        // When
        let actual = sut.makeSongToScrobble(currentItem: currentItem, cachedItem: cachedItem)
        
        // Then
        expect(actual).to(haveCount(1))
        verifyPlayedSong(actual[0],
             id: 1,
             date: "2018-01-29 15:16:00",
             artist: "The Dear Hunter",
             album: "Migrant",
             title: "Bring You Down"
        )
    }
    
    func test_makeSongToScrobble_doesNotScrobbleTheSongIfThePlayHasNotChanged() {
        // Given
        let currentItem = makeMediaItem(id: 1, lastPlayedDate: "2018-01-29 15:16:00", playCount: 1, artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        let cachedItem = makeCachedItem(id: 1, playCount: 1, lastPlayedDate: "2018-01-29 15:16:00")
        
        // When
        let actual = sut.makeSongToScrobble(currentItem: currentItem, cachedItem: cachedItem)
        
        // Then
        expect(actual).to(beEmpty())
    }
    
    func test_makeSongToScrobble_makesAsManySongsAsTheDifferenceInPlayCount() {
        // Given
        let currentItem = makeMediaItem(id: 1, lastPlayedDate: "2018-01-29 15:16:00", playCount: 3, artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        
        // When
        let actual = sut.makeSongToScrobble(currentItem: currentItem, cachedItem: nil)
        
        // Then
        expect(actual).to(haveCount(3))
        verifyPlayedSong(actual[0], id: 1, date: "2018-01-29 15:16:00", artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        verifyPlayedSong(actual[1], id: 1, date: "2018-01-29 15:15:59", artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        verifyPlayedSong(actual[2], id: 1, date: "2018-01-29 15:15:58", artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
    }
    
    func test_makeSongToScrobble_makesAsManySongsAsTheDifferenceInPlayCount_inCache() {
        // Given
        let currentItem = makeMediaItem(id: 1, lastPlayedDate: "2018-01-29 15:16:00", playCount: 8, artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        let cachedItem = makeCachedItem(id: 1, playCount: 4, lastPlayedDate: "2018-01-29 00:30:00")
        
        // When
        let actual = sut.makeSongToScrobble(currentItem: currentItem, cachedItem: cachedItem)
        
        // Then
        expect(actual).to(haveCount(4))
        verifyPlayedSong(actual[0], id: 1, date: "2018-01-29 15:16:00", artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        verifyPlayedSong(actual[1], id: 1, date: "2018-01-29 15:15:59", artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        verifyPlayedSong(actual[2], id: 1, date: "2018-01-29 15:15:58", artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        verifyPlayedSong(actual[3], id: 1, date: "2018-01-29 15:15:57", artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
    }

    func test_makeSongToScrobble_returnsArrayIfSongNotPlayed() {
        // Given
        let currentItem = makeMediaItem(id: 1, lastPlayedDate: nil, playCount: 0, artist: "The Dear Hunter", album: "Migrant", title: "Bring You Down")
        
        // When
        let actual = sut.makeSongToScrobble(currentItem: currentItem, cachedItem: nil)
        
        // Then
        expect(actual).to(beEmpty())
    }
    
    //
    // Helper Funcs
    //
    
    private func makeMediaItem(
        id: MediaItemId,
        lastPlayedDate dateString: String?,
        playCount: Int,
        artist: String,
        album: String,
        title: String
    ) -> MediaItem {
        let lastPlayedDate = dateString != nil ? Date.makeDate(from: dateString!) : nil
        let item = MediaItem(
            id: id,
            lastPlayedDate: lastPlayedDate,
            playCount: playCount,
            artist: artist,
            album: album,
            title: title
        )        
        return item
    }
    
    private func makeCachedItem(id: MediaItemId, playCount: Int, lastPlayedDate: String) -> ScrobbleMediaItem {
        var item = ScrobbleMediaItem(id: id)
        item.playCount = playCount
        item.lastPlayedDate = Date.makeDate(from: lastPlayedDate)
        return item
    }
    
    private func verifyPlayedSong(_ playedSong: PlayedSong?, id: MediaItemId, date dateString: String, artist: String, album: String, title: String) {
        guard let actual = playedSong else {
            expect(playedSong).toNot(beNil())
            return
        }
        
        let date = Date.makeDate(from: dateString)!
        expect(actual.id).to(equal(PlayedSongId(persistentId: 1, date: date)))
        expect(actual.date).to(equal(date))
        expect(actual.artist).to(equal(artist))
        expect(actual.album).to(equal(album))
        expect(actual.track).to(equal(title))
    }
}
