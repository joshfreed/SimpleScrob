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
    let albumArtist: String?
    let title: String?
    var playbackDuration: TimeInterval?
    
    init(item: MPMediaItem) {
        self.id = item.persistentID
        self.lastPlayedDate = item.lastPlayedDate
        self.playCount = item.playCount
        self.artist = item.artist
        self.album = item.albumTitle
        self.albumArtist = item.albumArtist
        self.title = item.title
        self.playbackDuration = item.playbackDuration
    }

    init(
        id: MediaItemId,
        lastPlayedDate: Date?,
        playCount: Int,
        artist: String?,
        album: String?,
        title: String?,
        albumArtist: String?
    ) {
        self.id = id
        self.lastPlayedDate = lastPlayedDate
        self.playCount = playCount
        self.artist = artist
        self.album = album
        self.albumArtist = albumArtist
        self.title = title
    }
}

// Constructs a played song and fills its aatributes from the given media item
extension PlayedSong {
    static func from(mediaItem: MediaItem, scrobbleDate: Date) -> PlayedSong {
        var song = PlayedSong(
            persistentId: mediaItem.id,
            date: scrobbleDate,
            artist: mediaItem.artist,
            album: mediaItem.album,
            track: mediaItem.title
        )
        song.albumArtist = mediaItem.albumArtist
        return song
    }
}

// stores the play count and last played date of a song the last time SimpleScrob read it
struct ScrobbleMediaItem: Equatable {
    let id: MediaItemId
    var playCount: Int = 0
    
    init(id: MediaItemId) {
        self.id = id
    }
    
    init(id: MediaItemId, playCount: Int) {
        self.id = id
        self.playCount = playCount
    }
    
    static func ==(lhs: ScrobbleMediaItem, rhs: ScrobbleMediaItem) -> Bool {
        return lhs.id == rhs.id
    }
}
