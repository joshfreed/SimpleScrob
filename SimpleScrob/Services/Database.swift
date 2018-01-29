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

protocol MediaItemStore {
    func findAll(byIds ids: [MediaItemId], completion: @escaping ([ScrobbleMediaItem]) -> ())
    func save(mediaItems: [ScrobbleMediaItem], completion: @escaping () -> ())
}

class MemoryMediaItemStore: MediaItemStore {
    private(set) var items: [ScrobbleMediaItem] = []
    
    func findAll(byIds ids: [MediaItemId], completion: @escaping ([ScrobbleMediaItem]) -> ()) {
        completion(items.filter({ ids.contains($0.id) }))
    }
    
    func save(mediaItems: [ScrobbleMediaItem], completion: @escaping () -> ()) {
        items = mediaItems
        completion()
    }
}
