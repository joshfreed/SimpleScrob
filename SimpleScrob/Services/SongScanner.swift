//
//  SongScanner.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/2/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import CocoaLumberjack
import DateToolsSwift

let ONE_HOUR: Double = 3600
let ONE_DAY: Double = ONE_HOUR * 24

class SongScannerImpl: SongScanner {
    let mediaLibrary: ScrobbleMediaLibrary
    let dateGenerator: DateGenerator
    let mediaItemStore: MediaItemStore
    let df = DateFormatter()
    
    var isInitialized: Bool {
        return UserDefaults.standard.bool(forKey: "musicLibraryIsInitialized")
    }

    /**
        Returns the date and time from which to look for songs that have been played.
     
        I have it returning 24 hours before the date and time you last scrobbled songs. I do this because
        there are times where songs played on another device and synced with iCloud Music Library don't
        sync immediately. 24 hours seems to catch all the plays.
    */
    var scrobbleSearchDate: Date {
        let lastSearchedAt = UserDefaults.standard.double(forKey: "lastScrobbleDate")
        let date = Date(timeIntervalSince1970: lastSearchedAt)
        let minSearchDate = date.addingTimeInterval(-ONE_DAY)
        
        if minSearchDate.isEarlier(than: initializationDate) {
            return initializationDate
        } else {
            return minSearchDate
        }
    }
    
    var initializationDate: Date {
        let initializedAt = UserDefaults.standard.double(forKey: "initlizationDate")
        return Date(timeIntervalSince1970: initializedAt)
    }
    
    init(mediaLibrary: ScrobbleMediaLibrary, dateGenerator: DateGenerator, mediaItemStore: MediaItemStore) {
        self.mediaLibrary = mediaLibrary
        self.dateGenerator = dateGenerator
        self.mediaItemStore = mediaItemStore
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func reset() {
        UserDefaults.standard.removeObject(forKey: "initlizationDate")
        UserDefaults.standard.removeObject(forKey: "lastScrobbleDate")
        UserDefaults.standard.removeObject(forKey: "musicLibraryIsInitialized")
    }
    
    func initializeSongDatabase() {
        UserDefaults.standard.set(true, forKey: "musicLibraryIsInitialized")
        UserDefaults.standard.set(dateGenerator.currentDate().timeIntervalSince1970, forKey: "initlizationDate")
        UserDefaults.standard.set(dateGenerator.currentDate().timeIntervalSince1970, forKey: "lastScrobbleDate")
    }
    
    func searchForNewScrobbles(completion: @escaping ([PlayedSong]) -> ()) {
        DDLogDebug("searchForNewScrobbles")
        DDLogInfo("Current Date: \(df.string(from: Date())), Last scan date: \(df.string(from: scrobbleSearchDate))")

        let recentlyPlayedItems = mediaLibrary.items(since: scrobbleSearchDate)
        DDLogDebug("Found \(recentlyPlayedItems.count) recently played songs")
        
        mediaItemStore.findAll(byIds: recentlyPlayedItems.map({ $0.id })) { cachedMediaItems in
            
            let songs = self.makeSongsToScrobble(currentMediaItems: recentlyPlayedItems, cachedMediaItems: cachedMediaItems)
            DDLogDebug("Found \(songs.count) songs to scrobble")
            
            self.updateLastScrobbleDate()
            
            let mediaItemIds = self.getUniqueMediaItemIds(from: songs)
            let itemsToUpdate = recentlyPlayedItems.filter({ mediaItemIds.contains($0.id) })
            self.updateCachedMediaItems(from: itemsToUpdate)

            completion(songs)
        }
    }
    
    private func getUniqueMediaItemIds(from songs: [PlayedSong]) -> [MediaItemId] {
        return Array(Set(songs.map({ $0.persistentId })))
    }
    
    func makeSongsToScrobble(currentMediaItems: [MediaItem], cachedMediaItems: [ScrobbleMediaItem]) -> [PlayedSong] {
        var playedSongs: [PlayedSong] = []
        
        for currentItem in currentMediaItems {
            let cachedItem = cachedMediaItems.filter({ $0.id == currentItem.id }).first
            playedSongs.append(contentsOf: makeSongToScrobble(currentItem: currentItem, cachedItem: cachedItem))
        }

        return playedSongs
    }
    
    func makeSongToScrobble(currentItem: MediaItem, cachedItem: ScrobbleMediaItem?) -> [PlayedSong] {
        let cachedPlayedCount = cachedItem?.playCount ?? 0
        return makePlayedSongForEachTimePlayed(currentItem: currentItem, cachedPlayCount: cachedPlayedCount)
    }
    
    private func makePlayedSongForEachTimePlayed(currentItem: MediaItem, cachedPlayCount: Int) -> [PlayedSong] {
        guard currentItem.playCount > cachedPlayCount else {
            return []
        }
        
        let numberOfPlaysToScrobble = currentItem.playCount - cachedPlayCount
        
        var songs: [PlayedSong] = []
        
        for i in 0..<numberOfPlaysToScrobble {
            let timeChunk = TimeChunk(seconds: i, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
            let overrideDate = currentItem.lastPlayedDate!.subtract(timeChunk)
            songs.append(makePlayedSong(from: currentItem, overrideLastPlayedDate: overrideDate))
        }
        
        return songs
    }
    
    private func makePlayedSong(from item: MediaItem, overrideLastPlayedDate: Date? = nil) -> PlayedSong {
        if item.lastPlayedDate == nil {
            // This should be impossible; to even get there the media item needs to have been played at least once
            DDLogError("MediaItem has been played but does not have a last played date? Id: \(item.id), play count: \(item.playCount)")
            fatalError("Media item has been played but does not have a last played date?")
        }
        
        let lastPlayedDate = overrideLastPlayedDate != nil ? overrideLastPlayedDate : item.lastPlayedDate
        
        return PlayedSong(
            persistentId: item.id,
            date: lastPlayedDate!,
            artist: item.artist,
            album: item.album,
            track: item.title
        )
    }
    
    private func updateLastScrobbleDate() {
        UserDefaults.standard.set(dateGenerator.currentDate().timeIntervalSince1970, forKey: "lastScrobbleDate")
    }
    
    private func updateCachedMediaItems(from currentItems: [MediaItem]) {
        let cachedItems = currentItems.map {
            ScrobbleMediaItem(id: $0.id, playCount: $0.playCount, lastPlayedDate: $0.lastPlayedDate)
        }
        mediaItemStore.save(mediaItems: cachedItems, completion: {})
    }
}
