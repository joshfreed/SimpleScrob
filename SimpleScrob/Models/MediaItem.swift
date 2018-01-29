//
//  MediaItem.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/9/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import UIKit
import MediaPlayer

typealias MediaItemId = MPMediaEntityPersistentID

//
// Representation of a song as it exists in the media library right now
//
struct MediaItem {
    let id: MediaItemId
    let lastPlayedDate: Date?
    let playCount: Int
    let artist: String?
    let album: String?
    let title: String?
    
    init(item: MPMediaItem) {
        self.id = item.persistentID
        self.lastPlayedDate = item.lastPlayedDate
        self.playCount = item.playCount
        self.artist = item.artist
        self.album = item.albumTitle
        self.title = item.title
    }

    init(
        id: MediaItemId,
        lastPlayedDate: Date?,
        playCount: Int,
        artist: String?,
        album: String?,
        title: String?
    ) {
        self.id = id
        self.lastPlayedDate = lastPlayedDate
        self.playCount = playCount
        self.artist = artist
        self.album = album
        self.title = title
    }
}

// stores the play count and last played date of a song the last time SimpleScrob read it
struct ScrobbleMediaItem: Equatable {
    let id: MediaItemId
    var playCount: Int = 0
    var lastPlayedDate: Date?
    
    init(id: MediaItemId) {
        self.id = id
    }
    
    init(id: MediaItemId, playCount: Int, lastPlayedDate: Date?) {
        self.id = id
        self.playCount = playCount
        self.lastPlayedDate = lastPlayedDate
    }
    
    static func ==(lhs: ScrobbleMediaItem, rhs: ScrobbleMediaItem) -> Bool {
        return lhs.id == rhs.id
    }
}
