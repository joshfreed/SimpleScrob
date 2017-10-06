//
//  SongScanner.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/2/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import os.log

class SongScanner {
    let mediaLibrary: MediaLibrary
    let database: Database
    let logger = OSLog(subsystem: "com.joshfreed.SimpleScrob", category: "SongScanner")
    
    var isInitialized: Bool {
        return UserDefaults.standard.bool(forKey: "musicLibraryIsInitialized")
    }

    var scrobbleSearchDate: Date? {
        let timestamp = UserDefaults.standard.double(forKey: "lastScrobbleDate")
        if timestamp > 0 {
            let lastScrobbleDate = Date(timeIntervalSince1970: timestamp)
            return lastScrobbleDate.addingTimeInterval(-86400)
        } else {
            return nil
        }
    }
    
    init(mediaLibrary: MediaLibrary, database: Database) {
        self.mediaLibrary = mediaLibrary
        self.database = database
        
//        UserDefaults.standard.removeObject(forKey: "musicLibraryIsInitialized")
    }
    
    func initializeSongDatabase() {
        os_log("initializeSongDatabase", log: logger, type: .debug)
        
        os_log("Clearing the song database", log: logger, type: .debug)
        
        database.clear()
        
        var songs: [SongID: Song] = [:]
        
        for item in mediaLibrary.items {
            let song = Song(
                id: item.persistentID,
                artist: item.artist,
                track: item.title,
                lastPlayedDate: item.lastPlayedDate,
                playCount: item.playCount
            )
            
            songs[song.id] = song
            
            os_log("Found song %@ by %@ with play count %i", log: logger, type: .debug, song.track ?? "", song.artist ?? "", song.playCount)
        }
        
        os_log("Inserting %i songs to the database", log: logger, type: .debug, songs.count)
        
        database.insert(Array(songs.values))
        
        UserDefaults.standard.set(true, forKey: "musicLibraryIsInitialized")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastScrobbleDate")
        
        os_log("initializeSongDatabase complete", log: logger, type: .debug)
    }
    
    func searchForNewScrobbles() -> [Song] {
        os_log("searchForNewScrobbles", log: logger, type: .debug)
        
        var songs: [Song] = []
        
        for item in mediaLibrary.items(since: scrobbleSearchDate) {
            os_log("MPMediaItem %u %@", log: logger, type: .debug, item.persistentID, item.title ?? "")
            
            // Leaving It Behind = 3351173376
            if let song = database.findById(item.persistentID) {
//                os_log("Song %u", log: logger, type: .debug, song.id)
                
                if item.playCount > song.playCount {
                    os_log("Song %u %@ has new play count %i", log: logger, type: .info, item.persistentID, item.title ?? "", item.playCount)
                    songs.append(song.updatedFrom(item: item))
                }
            }
        }
        
        os_log("Found %i songs to scrobble", log: logger, type: .debug, songs.count)
        
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastScrobbleDate")
        
        return songs
    }
}
