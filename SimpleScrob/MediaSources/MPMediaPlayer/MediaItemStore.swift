//
//  MediaItemStore.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/30/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import Foundation

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
