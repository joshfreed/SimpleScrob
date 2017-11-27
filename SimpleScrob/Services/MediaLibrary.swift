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

typealias MediaEntityPersistentId = MPMediaEntityPersistentID
typealias MediaItemArtwork = MPMediaItemArtwork

class MediaLibrary: ScrobbleMediaLibrary, ViewScrobblesArtworkFetcher {
    static let shared = MediaLibrary()
    
    private var _items: [MPMediaItem] {
        return MPMediaQuery.songs().items ?? []
    }
    
    var items: [MediaItem] {
        #if DEBUG
            return [
                MediaItem(persistentId: 3, lastPlayedDate: makeDate(string: "2017-11-25 21:36:00"), artist: "Beardfish", album: "Sleeping in Traffic: Part One", title: "And Never Know", artwork: nil),
                MediaItem(persistentId: 2, lastPlayedDate: makeDate(string: "2017-11-25 20:18:58"), artist: "Beardfish", album: "Sleeping in Traffic: Part One", title: "Afternoon Conversation", artwork: nil),
                MediaItem(persistentId: 1, lastPlayedDate: makeDate(string: "2017-11-19 18:18:58"), artist: "Beardfish", album: "Sleeping in Traffic: Part One", title: "Sunrise", artwork: nil),
                MediaItem(persistentId: 8, lastPlayedDate: makeDate(string: "2017-10-16 14:18:00"), artist: "Beardfish", album: "Sleeping in Traffic: Part One", title: "Year of the Knife", artwork: nil),
                MediaItem(persistentId: 7, lastPlayedDate: makeDate(string: "2017-10-11 10:15:00"), artist: "Coheed and Camria", album: "Good Apollo I'm Burning Star IV, Vol 1 - From Fear Through the Eyes of Madness", title: "The Willing Well I: Fuel for the Feeding End", artwork: nil),
                MediaItem(persistentId: 6, lastPlayedDate: makeDate(string: "2017-10-11 10:10:00"), artist: "Coheed and Camria", album: "Good Apollo I'm Burning Star IV, Vol 1 - From Fear Through the Eyes of Madness", title: "Welcome Home", artwork: nil),
                MediaItem(persistentId: 5, lastPlayedDate: makeDate(string: "2017-10-09 18:50:00"), artist: "Beardfish", album: "Sleeping in Traffic: Part One", title: "The Ungodly Slob", artwork: nil),
                MediaItem(persistentId: 4, lastPlayedDate: makeDate(string: "2017-10-09 18:45:00"), artist: "Beardfish", album: "Sleeping in Traffic: Part One", title: "Roulette", artwork: nil),
                MediaItem(persistentId: 3, lastPlayedDate: makeDate(string: "2017-10-09 18:40:00"), artist: "Beardfish", album: "Sleeping in Traffic: Part One", title: "And Never Know", artwork: nil),
                MediaItem(persistentId: 2, lastPlayedDate: makeDate(string: "2017-10-09 18:30:00"), artist: "Beardfish", album: "Sleeping in Traffic: Part One", title: "Afternoon Conversation", artwork: nil),
                MediaItem(persistentId: 1, lastPlayedDate: makeDate(string: "2017-10-09 18:20:00"), artist: "Beardfish", album: "Sleeping in Traffic: Part One", title: "Sunrise", artwork: nil)
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
    
    func artwork(for persistentId: MediaEntityPersistentId) -> MediaItemArtwork? {
        if let item = _items.first(where: { $0.persistentID == persistentId }) {
            return item.artwork
        } else {
            return nil
        }
    }
}
