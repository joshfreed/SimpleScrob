//
//  ScrobbleService.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/25/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation

protocol ScrobbleService: SignInAuthentication {
    var isLoggedIn: Bool { get }
    var currentUserName: String? { get }
    func authenticate(username: String, password: String, completion: @escaping (_ success: Bool) -> ())
    func signOut()
    func resumeSession()
    func scrobble(songs: [PlayedSong], completion: @escaping ([PlayedSong], Error?) -> ())
}

extension Notification.Name {
    static let signedIn = Notification.Name("signedIn")
    static let signedOut = Notification.Name("signedOut")
}
