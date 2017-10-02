//
//  LastFM.swift
//  SimpleScrob
//
//  Created by Josh Freed on 9/30/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation

class LastFM {
    static let shared = FakeLastFM()
    fileprivate init() {}
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    var currentUser: User? {
        return nil
    }
    
    func submit(songs: [Song], completion: @escaping () -> ()) {
        completion()
    }
}

class FakeLastFM: LastFM {
    override var currentUser: User? {
        return User(username: "flexxo")
//        return nil
    }
    
    override func submit(songs: [Song], completion: @escaping () -> ()) {
        delay(seconds: 2) {
            completion()
        }
    }
}
