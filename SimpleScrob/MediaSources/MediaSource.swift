//
//  MediaSource.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/30/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import Foundation

protocol MediaSource {
    var isInitialized: Bool { get }
    func initialize(completion: @escaping () -> ())
    func getSongsPlayedSinceLastTime(completion: @escaping ([PlayedSong]) -> ())
}
