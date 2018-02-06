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

class SongScanner: MediaSource {
    let mediaLibrary: ScrobbleMediaLibrary
    let dateGenerator: DateGenerator
    let mediaItemStore: MediaItemStore
    
    var isInitialized: Bool {
        return UserDefaults.standard.bool(forKey: "musicLibraryIsInitialized")
    }
    
    init(mediaLibrary: ScrobbleMediaLibrary, dateGenerator: DateGenerator, mediaItemStore: MediaItemStore) {
        self.mediaLibrary = mediaLibrary
        self.dateGenerator = dateGenerator
        self.mediaItemStore = mediaItemStore
    }

    func initialize(completion: @escaping () -> ()) {
        updateCachedMediaItems(from: mediaLibrary.items) {
            UserDefaults.standard.set(true, forKey: "musicLibraryIsInitialized")
            completion()
        }
    }
    
    func getSongsPlayedSinceLastTime(completion: @escaping ([PlayedSong]) -> ()) {
        DDLogDebug("searchForNewScrobbles")
        
        let currentMediaItems = mediaLibrary.items
        DDLogDebug("Found \(currentMediaItems.count) items in the media library")
        
        mediaItemStore.findAll(byIds: currentMediaItems.map({ $0.id })) { cachedMediaItems in
            DDLogDebug("Loaded \(cachedMediaItems.count) cached media items")
            
            let songs = self.makeSongsToScrobble(currentMediaItems: currentMediaItems, cachedMediaItems: cachedMediaItems)
            DDLogDebug("Found \(songs.count) songs played since last time")
            
            self.updateCachedMediaItems(from: currentMediaItems) {
                completion(songs)
            }
        }
    }
    
    func makeSongsToScrobble(currentMediaItems: [MediaItem], cachedMediaItems: [ScrobbleMediaItem]) -> [PlayedSong] {
        var playedSongs: [PlayedSong] = []
        let cachedItemsDictionary = cachedMediaItems.reduce(into: [MediaItemId: ScrobbleMediaItem]()) { $0[$1.id] = $1 }

        for currentItem in currentMediaItems {
            let cachedItem = cachedItemsDictionary[currentItem.id]
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
    
    private func updateCachedMediaItems(from currentItems: [MediaItem], completion: @escaping () -> ()) {
        DDLogDebug("updateCachedMediaItems")

        let cachedItems = currentItems.map {
            ScrobbleMediaItem(id: $0.id, playCount: $0.playCount, lastPlayedDate: $0.lastPlayedDate)
        }
        
        mediaItemStore.save(mediaItems: cachedItems, completion: completion)
    }
}
