//
//  SongPlay.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/6/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation

struct PlayedSongId: Equatable {
    let persistentId: MediaEntityPersistentId
    let date: Date

    init(persistentId: MediaEntityPersistentId, date: Date) {
        self.persistentId = persistentId
        self.date = date
    }
    
    static func ==(lhs: PlayedSongId, rhs: PlayedSongId) -> Bool {
        return lhs.persistentId == rhs.persistentId && lhs.date == rhs.date
    }
}

struct PlayedSong: Equatable {
    let id: PlayedSongId
    let persistentId: MediaEntityPersistentId
    var status: ScrobbleStatus = .notScrobbled
    var reason: LastFM.ErrorType?
    var date: Date
    var artist: String?
    var album: String?
    var track: String?
    var artwork: MediaItemArtwork?
    
    init(persistentId: MediaEntityPersistentId, date: Date) {
        self.id = PlayedSongId(persistentId: persistentId, date: date)
        self.persistentId = persistentId
        self.date = date
        self.status = .notScrobbled
    }
    
    init(persistentId: MediaEntityPersistentId, date: Date, status: ScrobbleStatus) {
        self.id = PlayedSongId(persistentId: persistentId, date: date)
        self.persistentId = persistentId
        self.date = date
        self.status = status
    }
    
    init(persistentId: MediaEntityPersistentId, date: Date, artist: String, album: String, track: String) {
        self.id = PlayedSongId(persistentId: persistentId, date: date)
        self.persistentId = persistentId
        self.date = date
        self.status = .notScrobbled
        self.artist = artist
        self.album = album
        self.track = track
    }
    
    init?(from item: MediaItem) {
        guard let date = item.lastPlayedDate else {
            return nil
        }
        
        persistentId = item.persistentId
        self.date = date
        artist = item.artist
        album = item.album
        track = item.title
        artwork = item.artwork
        id = PlayedSongId(persistentId: persistentId, date: date)
    }
    
    var scrobbleTimestamp: String? {
        return String(Int(date.timeIntervalSince1970))
    }
    
    mutating func scrobbled() {
        status = .scrobbled
    }
    
    mutating func notScrobbled(reason: LastFM.ErrorType) {
        status = .notScrobbled
        self.reason = reason
    }
    
    mutating func failedToScrobble(error: LastFM.ErrorType) {
        status = .failed
    }
    
    static func ==(lhs: PlayedSong, rhs: PlayedSong) -> Bool {
        return lhs.id == rhs.id
    }
}

enum ScrobbleStatus: String {
    case notScrobbled
    case scrobbled
    case ignored
    case failed
}
