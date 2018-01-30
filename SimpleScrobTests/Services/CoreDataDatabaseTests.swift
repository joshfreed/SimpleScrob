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

class CareDataDatabaseTests: XCTestCase {
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
    
    // Helper Funcs
    
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
