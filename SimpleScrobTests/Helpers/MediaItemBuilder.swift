//
//  MediaItemBuilder.swift
//  SimpleScrobTests
//
//  Created by Josh Freed on 2/6/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import Foundation
@testable import SimpleScrob

class MediaItemBuilder {
    private var lastId: MediaItemId = 1
    private var id: MediaItemId?
    private var lastPlayedDate: Date?
    private var playCount: Int = 0
    private var artist: String?
    private var album: String?
    private var title: String?
    private var duration: Int?
    
    static func anItem() -> MediaItemBuilder {
        return MediaItemBuilder()
    }
    
    static func anItem(id: MediaItemId) -> MediaItemBuilder {
        return MediaItemBuilder(id: id)
    }
    
    init() {
        
    }
    
    init(id: MediaItemId) {
        self.id = id
        lastId = max(lastId, id + 1)
    }
    
    func build() -> MediaItem {
        if id == nil {
            id = lastId
            lastId += 1
        }
        if artist == nil {
            artist = "Artist\(id)"
        }
        if album == nil {
            album = "Album\(id)"
        }
        if title == nil {
            title = "Track\(id)"
        }
        if playCount > 0 && lastPlayedDate == nil {
            lastPlayedDate = Date().subtract(10.minutes)
        }
        if duration == nil {
            duration = 300
        }
        
        var item = MediaItem(
            id: id!,
            lastPlayedDate: lastPlayedDate,
            playCount: playCount,
            artist: artist,
            album: album,
            title: title
        )
        item.playbackDuration = TimeInterval(duration!)
        return item
    }
    
    func with(id: MediaItemId) -> MediaItemBuilder {
        self.id = id
        return self
    }
    
    func with(artist: String) -> MediaItemBuilder {
        self.artist = artist
        return self
    }
    
    func with(album: String) -> MediaItemBuilder {
        self.album = album
        return self
    }
    
    func with(title: String) -> MediaItemBuilder {
        self.title = title
        return self
    }
    
    func lastPlayedAt(_ lastPlayedDate: Date) -> MediaItemBuilder {
        self.lastPlayedDate = lastPlayedDate
        return self
    }
    
    func lastPlayedAt(_ lastPlayedDate: String) -> MediaItemBuilder {
        self.lastPlayedDate = Date.makeDate(from: lastPlayedDate)
        return self
    }
    
    func with(playCount: Int) -> MediaItemBuilder {
        self.playCount = playCount
        return self
    }
    
    func neverPlayed() -> MediaItemBuilder {
        self.playCount = 0
        self.lastPlayedDate = nil
        return self
    }
    
    func withDuration(seconds: Int) -> MediaItemBuilder {
        self.duration = seconds
        return self
    }
}
