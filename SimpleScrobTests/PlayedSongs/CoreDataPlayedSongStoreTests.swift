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
        let actual = sut.findById(playedSong.id)
        
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
        let entity = NSEntityDescription.insertNewObject(forEntityName: "PlayedSong", into: container.viewContext) as! ManagedPlayedSong
        entity.persistentId = String(playedSong.persistentId)
        entity.datePlayed = playedSong.date
        entity.status = playedSong.status.rawValue
    }
    
    func saveContext() {
        do {
            try container.viewContext.save()
        } catch {
            XCTFail("Failed to insert entity")
        }
    }
}
