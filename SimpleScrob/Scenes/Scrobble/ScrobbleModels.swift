//
//  ScrobbleModels.swift
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

enum Scrobble {
    // MARK: Use cases

    enum Refresh {
        struct Request {
            var delay: Bool
        }

        struct Response {
        }

        struct ViewModel {
        }
    }
    
    enum InitializeMusicLibrary {
        struct Request {
            
        }
        
        struct Response {
            
        }
        
        struct ViewModel {
            
        }
    }
    
    enum SearchForNewScrobbles {
        struct Request {
            var autoSubmit: Bool
            var delay: Bool
        }
        
        struct Response {
            let songs: [PlayedSong]
        }
        
        struct ViewModel {
            let numberOfSongs: Int
        }
    }
    
    enum SubmitScrobbles {
        struct Request {

        }
        
        struct Response {
            let error: Error?
        }
        
        struct ViewModel {
            let error: String?
        }
    }

    enum GetCurrentUser {
        struct Request {
            
        }
        
        struct Response {
            let username: String?
        }
        
        struct ViewModel {
            let username: String?
        }
    }
    
    enum SignIn {
        struct Request {
            
        }
        
        struct Response {
            
        }
        
        struct ViewModel {
            var username: String
        }
    }
    
    enum SignOut {
        struct Request {
            
        }
        
        struct Response {
            
        }
        
        struct ViewModel {
            
        }
    }
}
