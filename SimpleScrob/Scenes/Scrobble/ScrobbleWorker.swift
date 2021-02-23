//
//  ScrobbleWorker.swift
//  SimpleScrob
//
//  Created by Josh Freed on 9/30/17.
//  Copyright (c) 2017 Josh Freed. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import CocoaLumberjack

class ScrobbleWorker {
    let database: PlayedSongStore
    let mediaSource: MediaSource
    let scrobbleService: ScrobbleService
    let connectivity: Connectivity
    
    var currentUserName: String? {
        return scrobbleService.currentUserName
    }
    
    var isLoggedIn: Bool {
        return scrobbleService.isLoggedIn
    }
    
    init(
        database: PlayedSongStore,
        mediaSource: MediaSource,
        scrobbleService: ScrobbleService,
        connectivity: Connectivity
    ) {
        self.database = database
        self.mediaSource = mediaSource
        self.scrobbleService = scrobbleService
        self.connectivity = connectivity
    }

    func signOut() {
        scrobbleService.signOut()
    }    
    
    func searchForNewSongsToScrobble(completion: @escaping ([PlayedSong]) -> ()) {
        mediaSource.getSongsPlayedSinceLastTime() { playedSongs in
            self.database.insert(playedSongs: playedSongs) {
                self.database.findUnscrobbledSongs { playedSongs in
                    DispatchQueue.main.async {
                        DDLogDebug("Found \(playedSongs.count) unscrobbled songs")
                        for song in playedSongs.sorted(by: { $0.date < $1.date }) {
                            DDLogDebug("\(song.track ?? "") by \(song.artist ?? "") on \(song.album ?? "") at \(song.date.format(with: "yyyy-MM-dd HH:mm:ss")). ID: \(song.id)")
                        }
                        completion(playedSongs)
                    }
                }
            }
        }
    }

    func submitUnscrobbledSongs(completion: @escaping ([PlayedSong], Error?) -> ()) {
        database.findUnscrobbledSongs { songs in
            guard songs.count > 0 else {
                completion([], nil)
                return
            }
            
            guard self.connectivity.isConnectedToInternet else {
                let updatedSongs = self.markNotScrobbled(songs: songs, with: ScrobbleError.notConnected.description)
                self.database.save(playedSongs: updatedSongs, completion: {})
                completion(updatedSongs, ScrobbleError.notConnected)
                return
            }
            
            self.scrobbleService.scrobble(songs: songs) { updatedSongs, error in
                self.database.save(playedSongs: updatedSongs, completion: {})
//                self.loveScrobbledSongs(songs: updatedSongs)
                completion(updatedSongs, error)
            }
        }
    }
    
    func loveScrobbledSongs(songs: [PlayedSong]) {
        DDLogDebug("Loving scrobbled songs")
        
        songs
            .filter({ $0.status == .scrobbled })
            .forEach {
                self.scrobbleService.love(song: $0, completion: { _ in })
            }        
    }
    
    func markNotScrobbled(songs: [PlayedSong], with reason: String) -> [PlayedSong] {
        var _songs = songs
        for i in 0..<_songs.count {
            _songs[i].notScrobbled(reason: reason)
        }
        return _songs
    }
}

enum ScrobbleError: Error, CustomStringConvertible {
    case notConnected
    
    var description: String {
        switch self {
        case .notConnected: return "Not connected to the Internet"
        }
    }
}
