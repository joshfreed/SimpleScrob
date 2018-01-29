//
//  SongPlay.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/6/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation

struct PlayedSongId: Equatable {
    let persistentId: MediaItemId
    let date: Date

    init(persistentId: MediaItemId, date: Date) {
        self.persistentId = persistentId
        self.date = date
    }
    
    static func ==(lhs: PlayedSongId, rhs: PlayedSongId) -> Bool {
        return lhs.persistentId == rhs.persistentId && lhs.date == rhs.date
    }
}

struct PlayedSong: Equatable {
    let id: PlayedSongId
    let persistentId: MediaItemId
    var status: ScrobbleStatus = .notScrobbled
    var reason: String?
    var date: Date
    var artist: String?
    var album: String?
    var track: String?
    var artwork: MediaItemArtwork?
    
    init(persistentId: MediaItemId, date: Date) {
        self.id = PlayedSongId(persistentId: persistentId, date: date)
        self.persistentId = persistentId
        self.date = date
        self.status = .notScrobbled
    }
    
    init(persistentId: MediaItemId, date: Date, status: ScrobbleStatus) {
        self.id = PlayedSongId(persistentId: persistentId, date: date)
        self.persistentId = persistentId
        self.date = date
        self.status = status
    }
    
    init(persistentId: MediaItemId, date: Date, artist: String?, album: String?, track: String?) {
        self.id = PlayedSongId(persistentId: persistentId, date: date)
        self.persistentId = persistentId
        self.date = date
        self.status = .notScrobbled
        self.artist = artist
        self.album = album
        self.track = track
    }

    var scrobbleTimestamp: String? {
        return String(Int(date.timeIntervalSince1970))
    }
    
    mutating func scrobbled() {
        status = .scrobbled
        reason = nil
    }
    
    mutating func notScrobbled(reason: String?) {
        status = .notScrobbled
        self.reason = reason
    }
    
    mutating func failedToScrobble(error: String?) {
        status = .failed
        reason = error
    }
    
    static func ==(lhs: PlayedSong, rhs: PlayedSong) -> Bool {
        return lhs.id == rhs.id
    }
}

enum ScrobbleStatus: String, RawRepresentable {
    case notScrobbled
    case scrobbled
    case ignored
    case failed
}
