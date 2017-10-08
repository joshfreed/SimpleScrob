//
//  SongPlay.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/6/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import MediaPlayer

struct PlayedSongId: Equatable {
    let persistentId: MPMediaEntityPersistentID
    let date: Date

    init(persistentId: MPMediaEntityPersistentID, date: Date) {
        self.persistentId = persistentId
        self.date = date
    }
    
    static func ==(lhs: PlayedSongId, rhs: PlayedSongId) -> Bool {
        return lhs.persistentId == rhs.persistentId && lhs.date == rhs.date
    }
}

struct PlayedSong: Equatable {
    let id: PlayedSongId
    let persistentId: MPMediaEntityPersistentID
    var status: ScrobbleStatus = .notScrobbled
    var date: Date
    var artist: String?
    var album: String?
    var track: String?
    var artwork: MPMediaItemArtwork?
    
    init(persistentId: MPMediaEntityPersistentID, date: Date) {
        self.id = PlayedSongId(persistentId: persistentId, date: date)
        self.persistentId = persistentId
        self.date = date
        self.status = .notScrobbled
    }
    
    init(persistentId: MPMediaEntityPersistentID, date: Date, status: ScrobbleStatus) {
        self.id = PlayedSongId(persistentId: persistentId, date: date)
        self.persistentId = persistentId
        self.date = date
        self.status = status
    }
    
    init(persistentId: MPMediaEntityPersistentID, date: Date, artist: String, album: String, track: String) {
        self.id = PlayedSongId(persistentId: persistentId, date: date)
        self.persistentId = persistentId
        self.date = date
        self.status = .notScrobbled
        self.artist = artist
        self.album = album
        self.track = track
    }
    
    init?(from item: MPMediaItem) {
        guard let date = item.lastPlayedDate else {
            return nil
        }
        
        persistentId = item.persistentID
        self.date = date
        artist = item.artist
        album = item.albumTitle
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
