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
    let dateGenerator: DateGenerator
    let logger = OSLog(subsystem: "com.joshfreed.SimpleScrob", category: "SongScanner")
    
    var isInitialized: Bool {
        return UserDefaults.standard.bool(forKey: "musicLibraryIsInitialized")
    }

    var scrobbleSearchDate: Date? {
        let lastSearchedAt = UserDefaults.standard.double(forKey: "lastScrobbleDate")
        let initializedAt = UserDefaults.standard.double(forKey: "initlizationDate")
        if lastSearchedAt > 0 {
            let date = Date(timeIntervalSince1970: lastSearchedAt)
            return date.addingTimeInterval(-3600)
        } else if initializedAt > 0 {
            return Date(timeIntervalSince1970: initializedAt)
        } else {
            return nil
        }
    }
    
    init(mediaLibrary: MediaLibrary, database: Database, dateGenerator: DateGenerator) {
        self.mediaLibrary = mediaLibrary
        self.database = database
        self.dateGenerator = dateGenerator
    }
    
    func reset() {
        UserDefaults.standard.removeObject(forKey: "initlizationDate")
        UserDefaults.standard.removeObject(forKey: "lastScrobbleDate")
        UserDefaults.standard.removeObject(forKey: "musicLibraryIsInitialized")
    }
    
    func initializeSongDatabase() {
        UserDefaults.standard.set(true, forKey: "musicLibraryIsInitialized")
        UserDefaults.standard.set(dateGenerator.currentDate().timeIntervalSince1970, forKey: "initlizationDate")
    }
    
    func searchForNewScrobbles() -> [PlayedSong] {
        os_log("searchForNewScrobbles", log: logger, type: .debug)
        
        var songs: [PlayedSong] = []
        
        if let scrobbleSearchDate = scrobbleSearchDate {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            os_log("Last scan date: %@", log: logger, type: .info, df.string(from: scrobbleSearchDate))
        }
        
        for item in mediaLibrary.items(since: scrobbleSearchDate) {
            if let playedSong = PlayedSong(from: item) {
                os_log("Song %@ - %u - %@", log: logger, type: .debug, playedSong.track ?? "", playedSong.persistentId, playedSong.date as NSDate)
                songs.append(playedSong)
            } else {
                os_log("Failed to create played song instance for %@ %@", log: logger, type: .error, item.title ?? "", item.artist ?? "")
            }
        }
        
        os_log("Found %i songs to scrobble", log: logger, type: .debug, songs.count)
        
        UserDefaults.standard.set(dateGenerator.currentDate().timeIntervalSince1970, forKey: "lastScrobbleDate")
        
        return songs
    }
}
