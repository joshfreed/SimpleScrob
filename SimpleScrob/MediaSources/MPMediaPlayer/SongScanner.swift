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
            
            self.updateCachedMediaItems(from: currentMediaItems) {
                completion(songs)
            }
        }
    }
    
    func makeSongsToScrobble(currentMediaItems: [MediaItem], cachedMediaItems: [ScrobbleMediaItem]) -> [PlayedSong] {
        let cachedItemsDictionary = cachedMediaItems.reduce(into: [MediaItemId: ScrobbleMediaItem]()) { $0[$1.id] = $1 }

        var playedSongs: [PlayedSong] = []
        
        for currentItem in currentMediaItems {
            let cachedItem = cachedItemsDictionary[currentItem.id]
            playedSongs.append(contentsOf: makePlayedSongsArray(currentItem: currentItem, cachedItem: cachedItem))
        }

        DDLogDebug("Found \(playedSongs.count) songs played since last time")
        
        return playedSongs
    }
    
    func makePlayedSongsArray(currentItem: MediaItem, cachedItem: ScrobbleMediaItem?) -> [PlayedSong] {
        let cachedPlayCount = cachedItem?.playCount ?? 0
        let timesPlayed = currentItem.playCount - cachedPlayCount
        return makePlayedSongsArray(from: currentItem, timesPlayed: timesPlayed)
    }
    
    func makePlayedSongsArray(from currentItem: MediaItem, timesPlayed: Int) -> [PlayedSong] {
        var songs: [PlayedSong] = []
        
        for i in 0..<timesPlayed {
            if let playedSong = makePlayedSong(from: currentItem, playedIndex: i) {
                songs.append(playedSong)
            }
        }
        
        return songs
    }
    
    func makePlayedSong(from item: MediaItem, playedIndex: Int) -> PlayedSong? {
        guard let lastPlayedDate = item.lastPlayedDate else {
            return nil
        }
        
        let duration = item.playbackDuration ?? 0
        var scrobbleDate = lastPlayedDate.addingTimeInterval(-duration)
        scrobbleDate = scrobbleDate.subtract(playedIndex.seconds)
        
        return PlayedSong(
            persistentId: item.id,
            date: scrobbleDate,
            artist: item.artist,
            album: item.album,
            track: item.title
        )
    }
    
    private func updateCachedMediaItems(from currentItems: [MediaItem], completion: @escaping () -> ()) {
        DDLogDebug("updateCachedMediaItems")

        let cachedItems = currentItems.map {
            ScrobbleMediaItem(id: $0.id, playCount: $0.playCount)
        }
        
        mediaItemStore.save(mediaItems: cachedItems, completion: completion)
    }
}
