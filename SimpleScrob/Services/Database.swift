//
//  Database.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/1/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import CoreData
import os.log

protocol Database {
    func clear()
    func findById(_ id: SongID) -> Song?
    func insert(_ songs: [Song])
    func save(_ songs: [Song])
}

class CoreDataDatabase: Database {
    let container: NSPersistentContainer
    let logger = OSLog(subsystem: "com.joshfreed.SimpleScrob", category: "CoreDataDatabase")
    
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
        os_log("Saving %i songs", log: logger, type: .info, songs.count)
        
        container.performBackgroundTask { context in
            let managedSongs = self.fetchManagedSongs(for: songs, in: context)
            
            for song in songs {
                if let managedSong = managedSongs.first(where: { $0.persistentID == String(song.id) }) {
                    managedSong.artist = song.artist
                    managedSong.track = song.track
                    managedSong.lastPlayedDate = song.lastPlayedDate
                    managedSong.lastPlayCount = Int16(song.playCount)
                    os_log("Updating song entity %@ %@ %i", log: self.logger, type: .debug, managedSong.persistentID ?? "", managedSong.track ?? "", managedSong.lastPlayCount)
                }
            }
            
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            os_log("Save complete", log: self.logger, type: .debug)
        }
    }
    
    private func fetchManagedSongs(for songs: [Song], in context: NSManagedObjectContext) -> [ManagedSong] {
        let request: NSFetchRequest<ManagedSong> = ManagedSong.fetchRequest()
        request.predicate = NSPredicate(format: "persistentID IN %@", songs.map({ String($0.id) }))
        let managedSongs: [ManagedSong]
        do {
            managedSongs = try context.fetch(request)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return managedSongs
    }
}
