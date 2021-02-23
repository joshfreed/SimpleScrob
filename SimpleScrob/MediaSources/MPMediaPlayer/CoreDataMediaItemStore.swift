//
//  CoreDataMediaItemStore.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/30/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import Foundation
import CoreData
import CocoaLumberjack

class CoreDataMediaItemStore: MediaItemStore {
    let container: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func findAll(byIds ids: [MediaItemId], completion: @escaping ([ScrobbleMediaItem]) -> ()) {
        // todo: make async? background thread?
        
        let managedItems = fetchManagedMediaItems(for: ids, in: container.viewContext)
        let models = managedItems.compactMap { CoreDataMediaItemTranslator.makeScrobbleMediaItem(entity: $0) }
        completion(models)
    }
    
    func save(mediaItems: [ScrobbleMediaItem], completion: @escaping () -> ()) {
        DDLogDebug("Saving \(mediaItems.count) media items")
        
        container.performBackgroundTask { context in
            let managedMediaItems = self.getManagedMediaItems(for: mediaItems, from: context)
            
            for item in mediaItems {
                let managedItem = managedMediaItems[String(item.id)]
                if let managedItem = managedItem {
                    managedItem.playCount = Int16(item.playCount)
                } else {
                    let _ = CoreDataMediaItemTranslator.makeEntity(from: item, into: context)
                }
            }
            
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            DDLogDebug("Save complete")
            
            completion()
        }
    }
    
    private func getManagedMediaItems(for mediaItems: [ScrobbleMediaItem], from context: NSManagedObjectContext) -> [String: ManagedMediaItem] {
        let managedMediaItems = self.fetchManagedMediaItems(for: mediaItems, in: context)
        return managedMediaItems.reduce(into: [String: ManagedMediaItem]()) {
            if let id = $1.persistentId {
                $0[id] = $1
            }
        }
    }
    
    private func fetchManagedMediaItems(for mediaItems: [ScrobbleMediaItem], in context: NSManagedObjectContext) -> [ManagedMediaItem] {
        let mediaItemIds = mediaItems.map({ $0.id })
        return fetchManagedMediaItems(for: mediaItemIds, in: context)
    }
    
    private func fetchManagedMediaItems(for mediaItemIds: [MediaItemId], in context: NSManagedObjectContext) -> [ManagedMediaItem] {
        let request: NSFetchRequest<ManagedMediaItem> = ManagedMediaItem.fetchRequest()
        request.predicate = NSPredicate(format: "persistentId IN %@", mediaItemIds.map({ String($0) }))
        let managedItems: [ManagedMediaItem]
        do {
            managedItems = try context.fetch(request)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return managedItems
    }
}

class CoreDataMediaItemTranslator {
    static func makeScrobbleMediaItem(entity: ManagedMediaItem) -> ScrobbleMediaItem? {
        guard
            let persistentIdStr = entity.persistentId,
            let persistentId = MediaItemId(persistentIdStr)
        else {
            return nil
        }
        return ScrobbleMediaItem(id: persistentId, playCount: Int(entity.playCount))
    }
    
    static func makeEntity(from model: ScrobbleMediaItem, into context: NSManagedObjectContext) -> ManagedMediaItem {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "MediaItem", into: context) as! ManagedMediaItem
        entity.persistentId = String(model.id)
        entity.playCount = Int16(model.playCount)
        return entity
    }
}
