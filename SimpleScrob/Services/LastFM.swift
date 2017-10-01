//
//  LastFM.swift
//  SimpleScrob
//
//  Created by Josh Freed on 9/30/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation

class LastFM {
    static let shared = LastFM()
    
    var isLoggedIn: Bool {
        return UserDefaults.standard.bool(forKey: "LastFM.isLoggedIn")
    }
}
