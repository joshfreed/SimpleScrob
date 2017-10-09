//
//  MediaLibrary.swift
//  SimpleScrob
//
//  Created by Josh Freed on 9/30/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import MediaPlayer
import JFLib

class MediaLibrary {
    static let shared = MediaLibrary()
    
    var items: [MPMediaItem] {
        return MPMediaQuery.songs().items ?? []
    }
    
    func items(since date: Date?) -> [MPMediaItem] {
        guard let date = date else {
            return items
        }
        
        return items.filter({
            guard let lastPlayedDate = $0.lastPlayedDate else {
                return false
            }
            return lastPlayedDate.timeIntervalSince1970 >= date.timeIntervalSince1970
        })
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
    
    func artwork(for persistentId: MPMediaEntityPersistentID) -> MPMediaItemArtwork? {
        if let item = items.first(where: { $0.persistentID == persistentId }) {
            return item.artwork
        } else {
            return nil
        }
    }
}
