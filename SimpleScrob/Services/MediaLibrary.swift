//
//  MediaLibrary.swift
//  SimpleScrob
//
//  Created by Josh Freed on 9/30/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import MediaPlayer

class MediaLibrary {
    static let shared = MediaLibrary()
    
    var isInitialized: Bool {
        return true
    }
    
    func isAuthorized() -> Bool {
        let status = MPMediaLibrary.authorizationStatus()
        return status == .authorized || status == .restricted
    }
    
    func authorizationDenied() -> Bool {
        return MPMediaLibrary.authorizationStatus() == .denied
    }
    
    func iterateSongs(each: @escaping (MPMediaItem) -> (), complete: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            if let items = MPMediaQuery.songs().items {
                print(items.count)
                
                for item in items {
                    print("\(item.persistentID), \(item.title), \(item.playCount)")
                    each(item)
                }
                
                DispatchQueue.main.sync {
                    complete()
                }
            }
        }
    }

    func scanMediaLibrary(completion: @escaping () -> ()) {
        iterateSongs(each: { item in
            
        }, complete: {
            delay(seconds: 2) {
                completion()
            }
        })
    }
    
    func searchForNewScrobbles(completion: @escaping ([Song]) -> ()) {
        iterateSongs(each: { item in
            
        }, complete: {
            var songs: [Song] = [
                Song(id: 1234, playCount: 4)
            ]
            
            delay(seconds: 2) {
                completion(songs)
            }
        })
        
        // For each item in the music library
        // Does it exist in the local database?
            // If yes - is the play count higher now?
                // If yes - scrobble this song. If the play count is higher by the more than one, scrobble this song multiple times (with different dates between the last scrobble time and last played time)
            // If no - insert it into the local database and scrobble it
        
    }
}
