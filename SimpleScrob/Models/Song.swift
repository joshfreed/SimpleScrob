//
//  Song.swift
//  SimpleScrob
//
//  Created by Josh Freed on 9/30/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import MediaPlayer

typealias SongID = MPMediaEntityPersistentID

struct Song: Equatable {
    var id: SongID
    var artist: String?
    var track: String?
    var lastPlayedDate: Date?
    var playCount: Int
    
    var scrobbleTimestamp: String? {
        guard let date = lastPlayedDate else {
            return nil
        }
        return String(Int(date.timeIntervalSince1970))
    }
    
    func updatedFrom(item: MPMediaItem) -> Song {
        return Song(
            id: item.persistentID,
            artist: item.artist,
            track: item.title,
            lastPlayedDate: item.lastPlayedDate,
            playCount: item.playCount
        )
    }
    
    static func ==(lhs: Song, rhs: Song) -> Bool {
        return lhs.id == rhs.id
    }
}
