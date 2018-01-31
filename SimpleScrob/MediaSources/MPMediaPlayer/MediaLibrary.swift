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
import CocoaLumberjack

typealias MediaItemArtwork = MPMediaItemArtwork

protocol ScrobbleMediaLibrary {
    var items: [MediaItem] { get }
    func items(since date: Date?) -> [MediaItem]
}

protocol MediaLibrary: ScrobbleMediaLibrary, ViewScrobblesArtworkFetcher {
    func isAuthorized() -> Bool
    func authorizationDenied() -> Bool
    func requestAuthorization(complete: @escaping () -> ())
}

class RealMediaLibrary: MediaLibrary {
    private var _items: [MPMediaItem] {
        return MPMediaQuery.songs().items ?? []
    }
    
    var items: [MediaItem] {
        DDLogDebug("Media library last modified at: \(MPMediaLibrary.default().lastModifiedDate.format(with: "yyyy-MM-dd HH:mm:ss"))")
        return _items.map { MediaItem(item: $0) }
    }
    
    func items(since date: Date?) -> [MediaItem] {
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
    
    func requestAuthorization(complete: @escaping () -> ()) {
        MPMediaLibrary.requestAuthorization { _ in
            DispatchQueue.main.sync {
                complete()
            }
        }
    }
    
    func artwork(for persistentId: MediaItemId) -> MediaItemArtwork? {
        if let item = _items.first(where: { $0.persistentID == persistentId }) {
            return item.artwork
        } else {
            return nil
        }
    }
}

class FakeMediaLibrary: MediaLibrary {
    var authorized: Bool?
    var items: [MediaItem] = []
    
    func isAuthorized() -> Bool {
        return authorized != nil && authorized!
    }
    
    func authorizationDenied() -> Bool {
        return authorized != nil && !authorized!
    }
    
    func requestAuthorization(complete: @escaping () -> ()) {
        authorized = true
        complete()
    }

    func items(since date: Date?) -> [MediaItem] {
        return items
    }
    
    func artwork(for persistentId: MediaItemId) -> MediaItemArtwork? {
        return nil
    }
}
