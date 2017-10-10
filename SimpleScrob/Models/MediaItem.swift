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

struct MediaItem {
    let persistentId: MediaItemId
    let lastPlayedDate: Date?
    let artist: String?
    let album: String?
    let title: String?
    let artwork: MPMediaItemArtwork?
    
    init(item: MPMediaItem) {
        self.persistentId = item.persistentID
        self.lastPlayedDate = item.lastPlayedDate
        self.artist = item.artist
        self.album = item.albumTitle
        self.title = item.title
        self.artwork = item.artwork
    }
    
    init(persistentId: MediaItemId, lastPlayedDate: Date?, artist: String?, album: String?, title: String?, artwork: MPMediaItemArtwork?) {
        self.persistentId = persistentId
        self.lastPlayedDate = lastPlayedDate
        self.artist = artist
        self.album = album
        self.title = title
        self.artwork = artwork
    }
}
