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

class MediaLibrary: ScrobbleMediaLibrary, ViewScrobblesArtworkFetcher {
    static let shared = MediaLibrary()
    
    private var _items: [MPMediaItem] {
        return MPMediaQuery.songs().items ?? []
    }
    
    var items: [MediaItem] {
        #if DEBUG
            return [
                MediaItem(id: 1, lastPlayedDate: makeDate(string: "2018-01-29 17:55:01"), playCount: 4, artist: "Beardfish", album: "Sleeping in Traffic: Part One", title: "Sunrise"),
                MediaItem(id: 3, lastPlayedDate: makeDate(string: "2018-01-29 17:54:03"), playCount: 1, artist: "Beardfish", album: "Sleeping in Traffic: Part One", title: "And Never Know"),
                MediaItem(id: 2, lastPlayedDate: makeDate(string: "2018-01-29 17:53:02"), playCount: 1, artist: "Beardfish", album: "Sleeping in Traffic: Part One", title: "Afternoon Conversation"),
            ]
        #else
            return _items.map { MediaItem(item: $0) }
        #endif
    }
    
    private func makeDate(string: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.date(from: string)
    }
    
    func debug() {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        DDLogInfo("Media library last modified at: \(df.string(from: MPMediaLibrary.default().lastModifiedDate))")
        
//        let songs = MPMediaQuery.songs().items ?? []
//        for song in songs {
//            let prettyDate = song.lastPlayedDate != nil ? df.string(from: song.lastPlayedDate!) : "N/A"
//            DDLogVerbose("\(song.persistentID) \(song.title ?? "N/A") \(prettyDate) \(song.playCount)")
//        }
    }
    
    func items(since date: Date?) -> [MediaItem] {
        guard let date = date else {
            return items
        }
        
        return items.filter({
            guard let lastPlayedDate = $0.lastPlayedDate else {
//                DDLogWarn("Item does not have last played date: \($0.artist ?? "??"), \($0.title ?? "??")")
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
