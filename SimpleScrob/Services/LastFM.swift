//
//  LastFM.swift
//  SimpleScrob
//
//  Created by Josh Freed on 9/30/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation
import JFLib

extension Notification.Name {
    static let signedIn = Notification.Name("signedIn")
    static let signedOut = Notification.Name("signedOut")
}

class LastFM {
    static let shared = FakeLastFM()
    fileprivate init() {}
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    var currentUser: User? {
        return nil
    }
    
    func resume() {
        
    }
    
    func signIn(username: String, password: String, completion: @escaping (Result<Bool>) -> ()) {
        NotificationCenter.default.post(name: .signedIn, object: nil)
        completion(.success(true))
    }
    
    func signOut() {
        NotificationCenter.default.post(name: .signedOut, object: nil)
    }
    
    func submit(songs: [Song], completion: @escaping () -> ()) {
        completion()
    }
}

class FakeLastFM: LastFM {
    private var _current: User?
    
    override var currentUser: User? {
        return _current
    }
    
    override func resume() {
        if let username = UserDefaults.standard.string(forKey: "username") {
            _current = User(username: username)
        }
    }
    
    override func signIn(username: String, password: String, completion: @escaping (Result<Bool>) -> ()) {
        UserDefaults.standard.set(username, forKey: "username")
        _current = User(username: username)
        delay(seconds: 2) {
            super.signIn(username: username, password: password, completion: completion)
        }
    }
    
    override func signOut() {
        UserDefaults.standard.removeObject(forKey: "username")
        _current = nil
        super.signOut()
    }
    
    override func submit(songs: [Song], completion: @escaping () -> ()) {
        delay(seconds: 2) {
            completion()
        }
    }
}
