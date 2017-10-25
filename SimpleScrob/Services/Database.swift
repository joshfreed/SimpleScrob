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
import MediaPlayer

protocol Database: GetRecentScrobbles {
    func findById(_ id: PlayedSongId) -> PlayedSong?
    func findUnscrobbledSongs(completion: @escaping ([PlayedSong]) -> ())
    func insert(playedSongs: [PlayedSong], completion: @escaping () -> ())
    func save(playedSongs: [PlayedSong], completion: @escaping () -> ())
    func getRecentScrobbles(completion: @escaping ([PlayedSong]) -> ())
}

class CoreDataDatabase: Database {
    let container: NSPersistentContainer
    let logger = OSLog(subsystem: "com.joshfreed.SimpleScrob", category: "CoreDataDatabase")
    
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
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    func findById(_ id: PlayedSongId) -> PlayedSong? {
        let request: NSFetchRequest<ManagedPlayedSong> = ManagedPlayedSong.fetchRequest()
        request.predicate = NSPredicate(format: "persistentId == %@ AND datePlayed == %@", String(id.persistentId), id.date as NSDate)
        
        var managedSong: ManagedPlayedSong?
        do {
            let managedSongs: [ManagedPlayedSong] = try container.viewContext.fetch(request)
            if managedSongs.count == 1 {
                managedSong = managedSongs.first
            } else if managedSongs.count > 1 {
                os_log("Found %i songs with the same id.", log: logger, type: .error, managedSongs.count)
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        if let managedSong = managedSong {
            return makePlayedSong(entity: managedSong)
        } else {
            return nil
        }
    }
    
    func findUnscrobbledSongs(completion: @escaping ([PlayedSong]) -> ()) {
        let request: NSFetchRequest<ManagedPlayedSong> = ManagedPlayedSong.fetchRequest()
        request.predicate = NSPredicate(format: "status != 'scrobbled'")
        
        let managedSongs: [ManagedPlayedSong]
        
        do {
            managedSongs = try container.viewContext.fetch(request)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        let playedSongs = managedSongs.flatMap(makePlayedSong)
        completion(playedSongs)
    }
    
    func makePlayedSong(entity: ManagedPlayedSong) -> PlayedSong? {
        guard
            let persistentIdStr = entity.persistentId,
            let persistentId = MPMediaEntityPersistentID(persistentIdStr),
            let statusStr = entity.status,
            let status = ScrobbleStatus(rawValue: statusStr),
            let date = entity.datePlayed
        else {
            return nil
        }
        
        var playedSong = PlayedSong(persistentId: persistentId, date: date, status: status)
        playedSong.artist = entity.artist
        playedSong.album = entity.album
        playedSong.track = entity.track
        return playedSong
    }
    
    func makeEntity(from playedSong: PlayedSong, into context: NSManagedObjectContext) -> ManagedPlayedSong {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "PlayedSong", into: context) as! ManagedPlayedSong
        entity.persistentId = String(playedSong.persistentId)
        entity.artist = playedSong.artist
        entity.album = playedSong.album
        entity.track = playedSong.track
        entity.datePlayed = playedSong.date
        entity.status = playedSong.status.rawValue
        return entity
    }
    
    func insert(playedSongs: [PlayedSong], completion: @escaping () -> ()) {
        container.performBackgroundTask { context in
            for song in playedSongs {
                if self.findById(song.id) == nil {
                    let _ = self.makeEntity(from: song, into: context)
                }
            }
            
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            completion()
        }
    }
    
    func save(playedSongs: [PlayedSong], completion: @escaping () -> ()) {
        os_log("Saving %i songs", log: logger, type: .info, playedSongs.count)
        
        container.performBackgroundTask { context in
            let managedSongs = self.fetchManagedPlayedSongs(for: playedSongs, in: context)
            
            for song in playedSongs {
                if let managedSong = managedSongs.first(where: {
                    $0.persistentId == String(song.persistentId) && $0.datePlayed == song.date
                }) {
//                    managedSong.artist = song.artist
//                    managedSong.album = song.album
//                    managedSong.track = song.track
//                    managedSong.datePlayed = song.date
                    managedSong.status = song.status.rawValue
                    os_log("Updating song entity %@ %@ %@ %@", log: self.logger, type: .debug, managedSong.persistentId ?? "", managedSong.track ?? "", managedSong.status ?? "", (managedSong.datePlayed as? NSDate) ?? NSDate(timeIntervalSince1970: 0))
                }
            }
            
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            os_log("Save complete", log: self.logger, type: .debug)
            
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
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return managedSongs
    }
    
    func getRecentScrobbles(completion: @escaping ([PlayedSong]) -> ()) {
        container.performBackgroundTask { context in
            let request: NSFetchRequest<ManagedPlayedSong> = ManagedPlayedSong.fetchRequest()
            
            var scrobbles: [ManagedPlayedSong]
            do {
                scrobbles = try context.fetch(request)
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            completion(scrobbles.flatMap(self.makePlayedSong).sorted(by: { $1.date < $0.date }))
        }
    }
}
