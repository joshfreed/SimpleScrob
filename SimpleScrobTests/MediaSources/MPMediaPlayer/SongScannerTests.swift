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
        deviceMediaLibrary._items = [
            MediaItemBuilder.anItem(id: 1).with(playCount: 2).build(),
            MediaItemBuilder.anItem(id: 2).with(playCount: 1).build(),
            MediaItemBuilder.anItem(id: 3).with(playCount: 3).build(),
            MediaItemBuilder.anItem(id: 4).neverPlayed().build()
        ]
        cachedMediaItemStore.items = [
            CachedMediaItemBuilder.anItem(id: 1).with(playCount: 1).build(),
            CachedMediaItemBuilder.anItem(id: 2).with(playCount: 1).build(),
            CachedMediaItemBuilder.anItem(id: 3).with(playCount: 2).build()
        ]
        var playedSongs: [PlayedSong] = []
        
        // When
        sut.getSongsPlayedSinceLastTime() { _playedSongs in
            playedSongs = _playedSongs
        }
        
        // Then
        expect(playedSongs).to(haveCount(2))
        expect(playedSongs[0].persistentId).to(equal(1))
        expect(playedSongs[1].persistentId).to(equal(3))
        expect(self.cachedMediaItemStore.save_savedItems).to(haveCount(4))
        expect(self.cachedMediaItemStore.save_savedItems).to(allPass({ [1, 2, 3, 4].contains($0!.id) }))
        expect(self.cachedMediaItemStore.save_savedItems?[0].playCount).to(equal(2))
        expect(self.cachedMediaItemStore.save_savedItems?[1].playCount).to(equal(1))
        expect(self.cachedMediaItemStore.save_savedItems?[2].playCount).to(equal(3))
        expect(self.cachedMediaItemStore.save_savedItems?[3].playCount).to(equal(0))
    }
    
    //
    // makeSongsToScrobble
    //
    
    func test_makeSongsToScrobble() {
        // Given
        let currentMediaItems = [
            MediaItemBuilder.anItem(id: 1).with(playCount: 1).build(),
            MediaItemBuilder.anItem(id: 2).with(playCount: 2).build(),
            MediaItemBuilder.anItem(id: 3).with(playCount: 1).build(),
        ]
        let cachedMediaItems: [ScrobbleMediaItem] = [
            CachedMediaItemBuilder.anItem(id: 2).with(playCount: 1).build(),
            CachedMediaItemBuilder.anItem(id: 3).with(playCount: 1).build()
        ]
        
        // When
        let actual = sut.makeSongsToScrobble(currentMediaItems: currentMediaItems, cachedMediaItems: cachedMediaItems)
        
        // Then
        expect(actual).to(haveCount(2))
        expect(actual[0].persistentId).to(equal(1))
        expect(actual[1].persistentId).to(equal(2))
    }
    
    //
    // makePlayedSongsArray
    //
    
    func test_makeSongToScrobble_mediaItemNotCachedYet() {
        // Given
        let currentItem = MediaItemBuilder.anItem(id: 1).with(playCount: 1).build()
        
        // When
        let actual = sut.makePlayedSongsArray(currentItem: currentItem, cachedItem: nil)
        
        // Then
        expect(actual).to(haveCount(1))
        expect(actual[0].persistentId).to(equal(1))
    }
    
    func test_makeSongToScrobble_currentPlayCountHigherThanTheCachedPlayCount() {
        // Given
        let currentItem = MediaItemBuilder.anItem(id: 1).with(playCount: 2).build()
        let cachedItem = CachedMediaItemBuilder.anItem(id: 1).with(playCount: 1).build()
        
        // When
        let actual = sut.makePlayedSongsArray(currentItem: currentItem, cachedItem: cachedItem)
        
        // Then
        expect(actual).to(haveCount(1))
        expect(actual[0].persistentId).to(equal(1))
    }
    
    func test_makeSongToScrobble_returnsEmptyArrayIfPlayCountsAreTheSame() {
        // Given
        let currentItem = MediaItemBuilder.anItem(id: 1).with(playCount: 3).build()
        let cachedItem = CachedMediaItemBuilder.anItem(id: 1).with(playCount: 3).build()
        
        // When
        let actual = sut.makePlayedSongsArray(currentItem: currentItem, cachedItem: cachedItem)
        
        // Then
        expect(actual).to(beEmpty())
    }
    
    func test_makeSongToScrobble_makesOnePlayedSongForEachTimeTheItemWasPlayed() {
        // Given
        let currentItem = MediaItemBuilder.anItem(id: 9).with(playCount: 6).build()
        let cachedItem = CachedMediaItemBuilder.anItem(id: 9).with(playCount: 3).build()
        
        // When
        let actual = sut.makePlayedSongsArray(currentItem: currentItem, cachedItem: cachedItem)
        
        // Then
        expect(actual).to(haveCount(3))
        expect(actual).to(allPass({ $0?.persistentId == 9 }))        
    }
    
    func test_makeSongToScrobble_returnsEmptyArrayIfTheSongWasNeverPlayed() {
        // Given
        let currentItem = MediaItemBuilder.anItem(id: 7).neverPlayed().build()
        
        // When
        let actual = sut.makePlayedSongsArray(currentItem: currentItem, cachedItem: nil)
        
        // Then
        expect(actual).to(beEmpty())
    }    
    
    //
    // makePlayedSong
    //
    
    func test_makePlayedSong_mapsMediaItemToPlayedSongModel() {
        let lastPlayedDate = Date().subtract(15.minutes)
        let duration = 400
        let playbackStartDate = lastPlayedDate.subtract(duration.seconds)
        let item = MediaItemBuilder
            .anItem()
            .lastPlayedAt(lastPlayedDate)
            .withDuration(seconds: duration)
            .withAlbumArtist("Something Someone")
            .build()
        
        let actual = sut.makePlayedSong(from: item, playedIndex: 0)
        
        expect(actual?.persistentId).to(equal(item.id))
        expect(actual?.date).to(equal(playbackStartDate))
        expect(actual?.artist).to(equal(item.artist))
        expect(actual?.album).to(equal(item.album))
        expect(actual?.track).to(equal(item.title))
        expect(actual?.status).to(equal(ScrobbleStatus.notScrobbled))
        expect(actual?.albumArtist).to(equal("Something Someone"))
    }
    
    func test_makePlayedSong_subtracts_1_second_from_the_scrobble_date_for_each_time_the_song_was_played() {
        // Given
        let lastPlayedDate = Date().subtract(15.minutes)
        let duration = 400
        let playbackStartDate = lastPlayedDate.subtract(duration.seconds)
        let scrobbleDate = playbackStartDate.subtract(3.seconds)
        let item = MediaItemBuilder.anItem().lastPlayedAt(lastPlayedDate).withDuration(seconds: duration).build()
        
        // When
        let actual = sut.makePlayedSong(from: item, playedIndex: 3)
        
        // Then
        expect(actual?.date).to(equal(scrobbleDate))
    }
}
