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

struct Song {
    var id: SongID
    var artist: String?
    var track: String?
    var lastPlayedDate: Date?
    var playCount: Int
}
