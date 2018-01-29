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
        return song
    }
    
    func with(status: ScrobbleStatus) -> PlayedSongBuilder {
        self.status = status
        return self
    }
}
