//
//  ViewScrobblesWorker.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/8/17.
//  Copyright (c) 2017 Josh Freed. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ViewScrobblesArtworkFetcher {
    func artwork(for persistentId: MediaItemId) -> MediaItemArtwork?
}

protocol GetRecentScrobbles {
    func getRecentScrobbles(skip: Int, limit: Int, completion: @escaping ([PlayedSong]) -> ())
}

class ViewScrobblesWorker {
    let database: GetRecentScrobbles
    let artworkService: ViewScrobblesArtworkFetcher
    let limit = 15
    
    init(database: GetRecentScrobbles, artworkService: ViewScrobblesArtworkFetcher) {
        self.database = database
        self.artworkService = artworkService
    }
    
    func getScrobbleHistory(completion: @escaping ([PlayedSong]) -> ()) {
        database.getRecentScrobbles(skip: 0, limit: limit) { scrobbles in
            let scrobblesWithArtwork = self.populateArtwork(scrobbles: scrobbles)
            completion(scrobblesWithArtwork)
        }
    }
    
    func loadMoreScrobbles(skip: Int, completion: @escaping ([PlayedSong], Bool) -> ()) {
        database.getRecentScrobbles(skip: skip, limit: limit) { scrobbles in
            let scrobblesWithArtwork = self.populateArtwork(scrobbles: scrobbles)
            let reachedEndOfItems = scrobbles.count < self.limit
            completion(scrobblesWithArtwork, reachedEndOfItems)
        }
    }
    
    private func populateArtwork(scrobbles: [PlayedSong]) -> [PlayedSong] {
        var scrobblesWithArtwork = scrobbles
        for i in 0..<scrobblesWithArtwork.count {
            scrobblesWithArtwork[i].artwork = self.artworkService.artwork(for: scrobblesWithArtwork[i].persistentId)
        }
        return scrobblesWithArtwork
    }
}
