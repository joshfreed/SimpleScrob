//
//  Database.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/1/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import CoreData

protocol Database {
    func clear()
    func findById(_ id: SongID) -> Song?
    func insert(_ song: Song)
    func insert(_ songs: [Song])
    func save(_ songs: [Song])
}

class MemoryDatabase: Database {
    var songs: [SongID: Song] = [:]
    
    func findById(_ id: SongID) -> Song? {
        return songs[id]
    }
    
    func clear() {
        songs = [:]
    }
    
    func insert(_ song: Song) {
        songs[song.id] = song
    }
    
    func insert(_ songs: [Song]) {
        
    }
    
    func save(_ songs: [Song]) {
        
    }
}

class CoreDataDatabase: Database {
    let container: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func clear() {
        deleteAllEntity("Song")
    }
    
    private func deleteAllEntity(_ entityName: String) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try container.viewContext.execute(request)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func findById(_ id: SongID) -> Song? {
        let request: NSFetchRequest<ManagedSong> = ManagedSong.fetchRequest()
        request.predicate = NSPredicate(format: "persistentID == %@", String(id))
        
        var managedSong: ManagedSong?
        do {
            let managedSongs: [ManagedSong] = try container.viewContext.fetch(request)
            if managedSongs.count == 1 {
                managedSong = managedSongs.first
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        if let managedSong = managedSong {
            return makeSong(from: managedSong)
        } else {
            return nil
        }
    }
    
    private func makeSong(from entity: ManagedSong) -> Song {
        return Song(
            id: SongID(entity.persistentID!)!,
            artist: entity.artist,
            track: entity.track,
            lastPlayedDate: entity.lastPlayedDate,
            playCount: Int(entity.lastPlayCount)
        )
    }
    
    private func makeEntity(from song: Song, into context: NSManagedObjectContext) -> ManagedSong {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Song", into: context) as! ManagedSong
        entity.persistentID = String(song.id)
        entity.artist = song.artist
        entity.track = song.track
        entity.lastPlayedDate = song.lastPlayedDate
        entity.lastPlayCount = Int16(song.playCount)
        return entity
    }
    
    func insert(_ song: Song) {
        let _ = makeEntity(from: song, into: container.viewContext)
        
        do {
            try container.viewContext.save()
        } catch {
            // sigh, error handling
        }
    }
    
    func insert(_ songs: [Song]) {
        container.performBackgroundTask { context in
            for song in songs {
                let _ = self.makeEntity(from: song, into: context)
            }
            
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    func save(_ songs: [Song]) {
        
    }
}
