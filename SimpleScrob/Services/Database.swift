//
//  Database.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/1/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation

protocol Database: GetRecentScrobbles {
    func findById(_ id: PlayedSongId) -> PlayedSong?
    func findUnscrobbledSongs(completion: @escaping ([PlayedSong]) -> ())
    func insert(playedSongs: [PlayedSong], completion: @escaping () -> ())
    func save(playedSongs: [PlayedSong], completion: @escaping () -> ())    
}
