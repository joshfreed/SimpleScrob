//
//  ViewScrobblesModels.swift
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

enum ViewScrobbles {
    struct DisplayedScrobble {
        let artist: String?
        let album: String?
        let track: String?
        let artwork: UIImage?
        let datePlayed: String
        let statusMessage: String
        let statusImageName: String
        let statusColor: UIColor
        let fullDate: String
    }
    
    // MARK: Use cases

    enum GetScrobbleHistory {
        struct Request {
        }

        struct Response {
            let scrobbles: [PlayedSong]
            let reachedEndOfItems: Bool
        }

        struct ViewModel {
            let scrobbles: [DisplayedScrobble]
            let reachedEndOfItems: Bool
        }
    }
    
    enum LoadMore {
        struct Request {
            
        }
        
        struct Response {
            let scrobbles: [PlayedSong]
        }
        
        struct ViewModel {
            let scrobbles: [DisplayedScrobble]
        }
    }
}
