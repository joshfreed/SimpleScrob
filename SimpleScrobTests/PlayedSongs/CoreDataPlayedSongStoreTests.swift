//
//  DatabaseTest.swift
//  SimpleScrobTests
//
//  Created by Josh Freed on 10/8/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import XCTest
import CoreData
@testable import SimpleScrob
import Nimble

class CoreDataPlayedSongStoreTests: XCTestCase {
    var sut: CoreDataPlayedSongStore!
    var container: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        container = setUpInMemoryPersistentContainer()
        sut = CoreDataPlayedSongStore(container: container)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFindById() {
        // Given
        let playedSong = PlayedSong(persistentId: 2, date: Date(timeIntervalSinceNow: -3300))
        insert(playedSong)
        saveContext()
        
        // When
        let actual = sut.findById(playedSong.id, in: container.viewContext)
        
        // Then
        expect(actual).toNot(beNil())
        expect(actual).to(equal(playedSong))
    }
    
    // MARK: insert
    
    func testInsertsSongs() {
        // Given
        let songs = [
            PlayedSong(persistentId: 1, date: Date(timeIntervalSinceNow: -3600)),
            PlayedSong(persistentId: 2, date: Date(timeIntervalSinceNow: -3300)),
            PlayedSong(persistentId: 3, date: Date(timeIntervalSinceNow: -3000)),
        ]
        let insertExpectation = expectation(description: "insert complete")
        
        // When
        sut.insert(playedSongs: songs) {
            insertExpectation.fulfill()
        }
        
        // Then
        wait(for: [insertExpectation], timeout: 5)
        let managedSongs = getAll()
        expect(managedSongs).to(haveCount(3))
    }
    
    func testInsertMapsSongPropertiesToCoreData() {
        // Given
        let song = PlayedSongBuilder
            .aSong()
            .playedAt("2018-03-28 14:15:16")
            .with(artist: "The Dear Hunter")
            .with(albumArtist: "TDH & BF")
            .with(album: "All Is As All Should Be")
            .with(track: "The Right Wrong")
            .with(status: ScrobbleStatus.notScrobbled, because: "Because reasons")
            .build()
        let songs = [song]
        let insertExpectation = expectation(description: "insert complete")
        
        // When
        sut.insert(playedSongs: songs) {
            insertExpectation.fulfill()
        }
        
        // Then
        wait(for: [insertExpectation], timeout: 5)
        let managedSong = getAll()[0]
        expect(managedSong.persistentId).to(equal(String(song.persistentId)))
        expect(managedSong.datePlayed).to(equal(song.date))
        expect(managedSong.artist).to(equal("The Dear Hunter"))
        expect(managedSong.albumArtist).to(equal("TDH & BF"))
        expect(managedSong.album).to(equal("All Is As All Should Be"))
        expect(managedSong.track).to(equal("The Right Wrong"))
        expect(managedSong.reason).to(equal("Because reasons"))
        expect(managedSong.status).to(equal(ScrobbleStatus.notScrobbled.rawValue))
    }
    
    func testDoesNotInsertSongsThatWereAlreadyInserted() {
        // Given
        let songs = [
            PlayedSong(persistentId: 1, date: Date(timeIntervalSinceNow: -3600)),
            PlayedSong(persistentId: 2, date: Date(timeIntervalSinceNow: -3300)),
            PlayedSong(persistentId: 3, date: Date(timeIntervalSinceNow: -3000)),
        ]
        let insertExpectation = expectation(description: "insert complete")
        insert(songs[1])
        saveContext()
        
        // When
        sut.insert(playedSongs: songs) {
            insertExpectation.fulfill()
        }
        
        // Then
        wait(for: [insertExpectation], timeout: 5)
        let managedSongs = getAll()
        expect(managedSongs).to(haveCount(3))
    }
    
    // MARK: findUnscrobbledSongs
    
    func test_findUnscrobbledSongs() {
        // Given
        let song1 = PlayedSongBuilder.aSong().with(status: .notScrobbled).build()
        let song2 = PlayedSongBuilder.aSong().with(status: .scrobbled).build()
        let song3 = PlayedSongBuilder.aSong().with(status: .ignored).build()
        let song4 = PlayedSongBuilder.aSong().with(status: .failed).build()
        insert(song1)
        insert(song2)
        insert(song3)
        insert(song4)
        saveContext()
        var unscrobbledSongs: [PlayedSong] = []
        let completionExpectation = expectation(description: "operation complete")
        
        // When
        sut.findUnscrobbledSongs { results in
            unscrobbledSongs = results
            completionExpectation.fulfill()
        }
        
        // Then
        wait(for: [completionExpectation], timeout: 5)
        expect(unscrobbledSongs).to(haveCount(2))
        expect(unscrobbledSongs).to(containElementSatisfying({ $0.id == song1.id }))
        expect(unscrobbledSongs).to(containElementSatisfying({ $0.id == song4.id }))
    }
    
    // MARK: Make played song
    
    func testMakePlayedSongFromEntity() {
        // Given
        let song = PlayedSongBuilder
            .aSong()
            .playedAt("2018-03-28 14:15:16")
            .with(artist: "The Dear Hunter")
            .with(albumArtist: "TDH & BF")
            .with(album: "All Is As All Should Be")
            .with(track: "The Right Wrong")
            .with(status: ScrobbleStatus.notScrobbled, because: "Because reasons")
            .build()
        insert(song)
        saveContext()
        let managedSong = getAll().first!
        
        // When
        let actual = sut.makePlayedSong(entity: managedSong)
        
        // Then
        expect(actual).toNot(beNil())
        expect(actual?.persistentId).to(equal(song.persistentId))
        expect(actual?.date).to(equal(song.date))
        expect(actual?.artist).to(equal("The Dear Hunter"))
        expect(actual?.albumArtist).to(equal("TDH & BF"))
        expect(actual?.album).to(equal("All Is As All Should Be"))
        expect(actual?.track).to(equal("The Right Wrong"))
        expect(actual?.reason).to(equal("Because reasons"))
        expect(actual?.status).to(equal(ScrobbleStatus.notScrobbled))
    }
    
    // MARK: Helper Funcs
    
    func getAll() -> [ManagedPlayedSong] {
        let request: NSFetchRequest<ManagedPlayedSong> = ManagedPlayedSong.fetchRequest()
        
        var managedSongs: [ManagedPlayedSong]
        do {
            managedSongs = try container.viewContext.fetch(request)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return managedSongs
    }
    
    func insert(_ playedSong: PlayedSong) {
        _ = sut.makeEntity(from: playedSong, into: container.viewContext)
    }
    
    func saveContext() {
        do {
            try container.viewContext.save()
        } catch {
            XCTFail("Failed to insert entity")
        }
    }
}
