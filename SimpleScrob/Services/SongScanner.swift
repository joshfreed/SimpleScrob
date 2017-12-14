//
//  SongScanner.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/2/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import CocoaLumberjack

let ONE_HOUR: Double = 3600
let ONE_DAY: Double = ONE_HOUR * 24

class SongScannerImpl: SongScanner {
    let mediaLibrary: ScrobbleMediaLibrary
    let dateGenerator: DateGenerator
    
    var isInitialized: Bool {
        return UserDefaults.standard.bool(forKey: "musicLibraryIsInitialized")
    }

    var scrobbleSearchDate: Date? {
        let lastSearchedAt = UserDefaults.standard.double(forKey: "lastScrobbleDate")
        let initializedAt = UserDefaults.standard.double(forKey: "initlizationDate")
        if lastSearchedAt > 0 {
            let date = Date(timeIntervalSince1970: lastSearchedAt)
            return date.addingTimeInterval(-ONE_DAY)
        } else if initializedAt > 0 {
            return Date(timeIntervalSince1970: initializedAt)
        } else {
            return nil
        }
    }
    
    init(mediaLibrary: ScrobbleMediaLibrary, dateGenerator: DateGenerator) {
        self.mediaLibrary = mediaLibrary
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
        DDLogDebug("searchForNewScrobbles")
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var songs: [PlayedSong] = []
        
        if let scrobbleSearchDate = scrobbleSearchDate {
            DDLogInfo("Current Date: \(df.string(from: Date())), Last scan date: \(df.string(from: scrobbleSearchDate))")
        }
        
        for item in mediaLibrary.items(since: scrobbleSearchDate) {
            if let playedSong = PlayedSong(from: item) {
                DDLogDebug("Song \(playedSong.track ?? "") - \(playedSong.persistentId) - \(df.string(from: playedSong.date))")
                songs.append(playedSong)
            } else {
                DDLogError("Failed to create played song instance for \(item.title ?? "") \(item.artist ?? "")")
            }
        }
        
        DDLogDebug("Found \(songs.count) recently played songs")

        UserDefaults.standard.set(dateGenerator.currentDate().timeIntervalSince1970, forKey: "lastScrobbleDate")
        
        return songs
    }
}
