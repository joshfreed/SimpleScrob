//
//  PlayedSongBuilder.swift
//  SimpleScrobTests
//
//  Created by Josh Freed on 1/4/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import Foundation
@testable import SimpleScrob

class PlayedSongBuilder {
    private var lastId: MediaItemId = 1
    private var persistentId: MediaItemId?
    private var playedDate: Date?
    private var status: ScrobbleStatus?
    private var artist: String?
    private var album: String?
    private var track: String?
    
    static func aSong() -> PlayedSongBuilder {
        return PlayedSongBuilder()
    }
    
    func build() -> PlayedSong {
        if persistentId == nil {
            persistentId = lastId
            lastId += 1
        }
        if playedDate == nil {
            playedDate = Date()
        }
        var song = PlayedSong(persistentId: persistentId!, date: playedDate!)
        if let status = status {
            song.status = status
        }
        song.artist = artist
        song.album = album
        song.track = track
        return song
    }
    
    func with(status: ScrobbleStatus) -> PlayedSongBuilder {
        self.status = status
        return self
    }
    
    func with(artist: String) -> PlayedSongBuilder {
        self.artist = artist
        return self
    }
    
    func with(album: String) -> PlayedSongBuilder {
        self.album = album
        return self
    }
    
    func with(track: String) -> PlayedSongBuilder {
        self.track = track
        return self
    }
    
    func playedAt(_ playedDate: Date) -> PlayedSongBuilder {
        self.playedDate = playedDate
        return self
    }
    
    func playedAt(_ playedDate: String) -> PlayedSongBuilder {
        self.playedDate = Date.makeDate(from: playedDate)
        return self
    }
}
