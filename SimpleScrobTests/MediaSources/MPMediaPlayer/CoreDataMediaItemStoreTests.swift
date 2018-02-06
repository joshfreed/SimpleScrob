//
//  CoreDataMediaItemStoreTests.swift
//  SimpleScrobTests
//
//  Created by Josh Freed on 1/30/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import XCTest
@testable import SimpleScrob
import CoreData
import Nimble

class CoreDataMediaItemStoreTests: XCTestCase {
    var sut: CoreDataMediaItemStore!
    var container: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        container = setUpInMemoryPersistentContainer()
        sut = CoreDataMediaItemStore(container: container)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFindAllByIds() {
        // Given
        let item1 = ScrobbleMediaItem(id: 1)
        let item2 = ScrobbleMediaItem(id: 2)
        let item3 = ScrobbleMediaItem(id: 3)
        insert(item1)
        insert(item2)
        insert(item3)
        saveContext()
        let completionExpectation = expectation(description: "operation complete")
        
        // When
        var foundItems: [ScrobbleMediaItem] = []
        sut.findAll(byIds: [1, 3]) { result in
            foundItems = result
            completionExpectation.fulfill()
        }
        
        // Then
        wait(for: [completionExpectation], timeout: 5)
        expect(foundItems).to(haveCount(2))
        expect(foundItems).to(contain([item1, item3]))
    }
    
    func testSave_insertsNewEntities() {
        // Given
        let item1 = ScrobbleMediaItem(id: 1)
        let item2 = ScrobbleMediaItem(id: 2)
        let completionExpectation = expectation(description: "operation complete")
        
        // When
        sut.save(mediaItems: [item1, item2]) {
            completionExpectation.fulfill()
        }
        
        // Then
        wait(for: [completionExpectation], timeout: 5)
        let managedItems = getAll()
        expect(managedItems).to(haveCount(2))
        expect(managedItems).to(containElementSatisfying({ item in item.persistentId == String(1) }))
        expect(managedItems).to(containElementSatisfying({ item in item.persistentId == String(2) }))
    }
    
    func testSave_updatesExistingEntitiesFromTheGivenItems() {
        // Given
        let initialItem = ScrobbleMediaItem(id: 1, playCount: 2)
        let updatedItem = ScrobbleMediaItem(id: 1, playCount: 5)
        insert(initialItem)
        saveContext()
        let completionExpectation = expectation(description: "operation complete")
        
        // When
        sut.save(mediaItems: [updatedItem]) {
            completionExpectation.fulfill()
        }
        
        // Then
        wait(for: [completionExpectation], timeout: 5)
        let managedItems = getAll()
        expect(managedItems).to(haveCount(1))
        expect(managedItems[0].persistentId).to(equal(String(1)))
        expect(managedItems[0].playCount).to(equal(5))
    }
    
    //
    // Helper Funcs
    //
    
    func getAll() -> [ManagedMediaItem] {
        let request: NSFetchRequest<ManagedMediaItem> = ManagedMediaItem.fetchRequest()
        
        var managedItems: [ManagedMediaItem]
        do {
            managedItems = try container.viewContext.fetch(request)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return managedItems
    }
    
    func insert(_ mediaItem: ScrobbleMediaItem) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "MediaItem", into: container.viewContext) as! ManagedMediaItem
        entity.persistentId = String(mediaItem.id)
        entity.playCount = Int16(mediaItem.playCount)
    }
    
    func saveContext() {
        do {
            try container.viewContext.save()
        } catch {
            XCTFail("Failed to save context")
        }
    }
}
