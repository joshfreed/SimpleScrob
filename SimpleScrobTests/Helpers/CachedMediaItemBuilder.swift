//
//  CachedMediaItemBuilder.swift
//  SimpleScrobTests
//
//  Created by Josh Freed on 2/6/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import Foundation
@testable import SimpleScrob

class CachedMediaItemBuilder {
    private let id: MediaItemId
    private var playCount = 0
    
    static func anItem(id: MediaItemId) -> CachedMediaItemBuilder {
        return CachedMediaItemBuilder(id: id)
    }
    
    init(id: MediaItemId) {
        self.id = id
    }
    
    func build() -> ScrobbleMediaItem {
        return ScrobbleMediaItem(id: id, playCount: playCount)
    }
    
    func with(playCount: Int) -> CachedMediaItemBuilder {
        self.playCount = playCount
        return self
    }
    
    func neverPlayed() -> CachedMediaItemBuilder {
        self.playCount = 0
        return self
    }
}
