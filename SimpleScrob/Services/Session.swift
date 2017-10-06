//
//  Session.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/5/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let signedIn = Notification.Name("signedIn")
}

class Session {
    private(set) var sessionKey: String?
    private(set) var currentUser: User?
    
    func start(sessionKey: String?, username: String) {
        self.sessionKey = sessionKey
        self.currentUser = User(username: username)
        
        UserDefaults.standard.set(self.sessionKey, forKey: "sessionKey")
        UserDefaults.standard.set(username, forKey: "username")
        
        NotificationCenter.default.post(name: .signedIn, object: nil)
    }
    
    func end() {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "sessionKey")
        currentUser = nil
    }
    
    func resume() {
        sessionKey = UserDefaults.standard.string(forKey: "sessionKey")
        
        if let username = UserDefaults.standard.string(forKey: "username") {
            currentUser = User(username: username)
        }
    }
}
