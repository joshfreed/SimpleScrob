//
//  Database.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/1/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation

protocol Database {
    func save(_ songs: [Song])
}

class MemoryDatabase: Database {
    func save(_ songs: [Song]) {
        
    }
}
