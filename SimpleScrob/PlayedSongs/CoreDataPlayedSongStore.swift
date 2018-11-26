//
//  CoreDataDatabase.swift
//  SimpleScrob
//
//  Created by Josh Freed on 11/11/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import CoreData
import CocoaLumberjack

class CoreDataPlayedSongStore: PlayedSongStore {
    let container: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.container = container
        //        clearPlayedSongs()
    }
    
    func clearPlayedSongs() {
        deleteAllEntity("PlayedSong")
    }
    
    private func deleteAllEntity(_ entityName: String) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try container.viewContext.execute(request)
        } catch {
            let nserror = error as NSError
            DDLogError("Unresolved error \(nserror), \(nserror.userInfo)")
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func findById(_ id: PlayedSongId, in context: NSManagedObjectContext) -> PlayedSong? {
        let request: NSFetchRequest<ManagedPlayedSong> = ManagedPlayedSong.fetchRequest()
        request.predicate = NSPredicate(format: "persistentId == %@ AND datePlayed == %@", String(id.persistentId), id.date as NSDate)
        
        var managedSong: ManagedPlayedSong?
        do {
            let managedSongs: [ManagedPlayedSong] = try context.fetch(request)
            if managedSongs.count == 1 {
                managedSong = managedSongs.first
            } else if managedSongs.count > 1 {
                DDLogError("Found \(managedSongs.count) songs with the same id")
            }
        } catch {
            let nserror = error as NSError
            DDLogError("Unresolved error \(nserror), \(nserror.userInfo)")
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        if let managedSong = managedSong {
            return makePlayedSong(entity: managedSong)
        } else {
            return nil
        }
    }
    
    func findUnscrobbledSongs(completion: @escaping ([PlayedSong]) -> ()) {
        DDLogVerbose("Finding unscrobbled songs")

        container.performBackgroundTask { context in
            let request: NSFetchRequest<ManagedPlayedSong> = ManagedPlayedSong.fetchRequest()
            request.predicate = NSPredicate(format: "status != 'scrobbled' && status != 'ignored'")
            
            let managedSongs: [ManagedPlayedSong]
            
            do {
                managedSongs = try context.fetch(request)
            } catch {
                let nserror = error as NSError
                DDLogError("Unresolved error \(nserror), \(nserror.userInfo)")
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            let playedSongs = managedSongs.compactMap(self.makePlayedSong)
            DDLogVerbose("Found \(playedSongs.count) unscrobbled songs from core data")
            completion(playedSongs)
        }
    }
    
    func makePlayedSong(entity: ManagedPlayedSong) -> PlayedSong? {
        guard
            let persistentIdStr = entity.persistentId,
            let persistentId = MediaItemId(persistentIdStr),
            let statusStr = entity.status,
            let status = ScrobbleStatus(rawValue: statusStr),
            let date = entity.datePlayed
        else {
            return nil
        }
        
        var playedSong = PlayedSong(persistentId: persistentId, date: date, status: status)
        playedSong.artist = entity.artist
        playedSong.albumArtist = entity.albumArtist
        playedSong.album = entity.album
        playedSong.track = entity.track
        playedSong.reason = entity.reason
        return playedSong
    }
    
    func makeEntity(from playedSong: PlayedSong, into context: NSManagedObjectContext) -> ManagedPlayedSong {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "PlayedSong", into: context) as! ManagedPlayedSong
        entity.persistentId = String(playedSong.persistentId)
        entity.artist = playedSong.artist
        entity.albumArtist = playedSong.albumArtist
        entity.album = playedSong.album
        entity.track = playedSong.track
        entity.datePlayed = playedSong.date
        entity.status = playedSong.status.rawValue
        entity.reason = playedSong.reason
        return entity
    }
    
    func insert(playedSongs: [PlayedSong], completion: @escaping () -> ()) {
        DDLogVerbose("Inserting new played songs. Count: \(playedSongs.count)")
        container.performBackgroundTask { context in
            for song in playedSongs {
                if self.findById(song.id, in: context) == nil {
                    let _ = self.makeEntity(from: song, into: context)
                }
            }
            
            do {
                try context.save()
            } catch {
                DDLogError("Failure to save context: \(error)")
                fatalError("Failure to save context: \(error)")
            }
            
            DDLogVerbose("Done inserting new played songs")
            completion()
        }
    }
    
    func save(playedSongs: [PlayedSong], completion: @escaping () -> ()) {
        DDLogDebug("Saving \(playedSongs.count) songs")
        
        container.performBackgroundTask { context in
            let managedSongs = self.fetchManagedPlayedSongs(for: playedSongs, in: context)
            
            for song in playedSongs {
                if let managedSong = managedSongs.first(where: {
                    $0.persistentId == String(song.persistentId) && $0.datePlayed == song.date
                }) {
                    managedSong.status = song.status.rawValue
                    managedSong.reason = song.reason
                    DDLogVerbose("Updating song entity \(managedSong.persistentId ?? ""), \(managedSong.track ?? ""), \(managedSong.status ?? ""), \(managedSong.reason ?? ""), \(String(describing: managedSong.datePlayed))")
                }
            }
            
            do {
                try context.save()
            } catch {
                DDLogError("Failure to save context: \(error)")
                fatalError("Failure to save context: \(error)")
            }
            
            DDLogDebug("Save complete")
            
            completion()
        }
    }
    
    private func fetchManagedPlayedSongs(for songs: [PlayedSong], in context: NSManagedObjectContext) -> [ManagedPlayedSong] {
        let request: NSFetchRequest<ManagedPlayedSong> = ManagedPlayedSong.fetchRequest()
        request.predicate = NSPredicate(format: "persistentId IN %@", songs.map({ String($0.persistentId) }))
        let managedSongs: [ManagedPlayedSong]
        do {
            managedSongs = try context.fetch(request)
        } catch {
            let nserror = error as NSError
            DDLogError("Unresolved error \(nserror), \(nserror.userInfo)")
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return managedSongs
    }
    
    func getRecentScrobbles(skip: Int, limit: Int, completion: @escaping ([PlayedSong]) -> ()) {
        container.performBackgroundTask { context in
            let request: NSFetchRequest<ManagedPlayedSong> = ManagedPlayedSong.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "datePlayed", ascending: false)]
            request.fetchLimit = 15
            request.fetchOffset = skip
            
            var scrobbles: [ManagedPlayedSong]
            do {
                scrobbles = try context.fetch(request)
            } catch {
                let nserror = error as NSError
                DDLogError("Unresolved error \(nserror), \(nserror.userInfo)")
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            completion(scrobbles.flatMap(self.makePlayedSong))
        }
    }
}
