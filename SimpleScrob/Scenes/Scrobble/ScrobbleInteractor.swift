//
//  ScrobbleInteractor.swift
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
import CocoaLumberjack
import JFLib

protocol ScrobbleBusinessLogic {
    func refresh(request: Scrobble.Refresh.Request)
    func searchForNewScrobbles(request: Scrobble.SearchForNewScrobbles.Request)
    func submitScrobbles(request: Scrobble.SubmitScrobbles.Request)
    func getCurrentUser(request: Scrobble.GetCurrentUser.Request)
    func signOut(request: Scrobble.SignOut.Request)
}

protocol ScrobbleDataStore {
    
}

class ScrobbleInteractor: ScrobbleBusinessLogic, ScrobbleDataStore {
    var presenter: ScrobblePresentationLogic?
    let worker: ScrobbleWorker

    private var isRefreshing: Bool {
        return isSearchingForScrobbles || isSubmittingScrobbles
    }
    private var isSearchingForScrobbles = false
    private var isSubmittingScrobbles = false
    
    init(worker: ScrobbleWorker) {
        self.worker = worker
        
        NotificationCenter.default.addObserver(self, selector: #selector(userSignedIn), name: .signedIn, object: nil)
    }
    
    // MARK: Events
    
    @objc func userSignedIn() {
        let response = Scrobble.GetCurrentUser.Response(username: worker.currentUserName)
        presenter?.presentCurrentUser(response: response)

        let request = Scrobble.SearchForNewScrobbles.Request(autoSubmit: true, delay: false)
        searchForNewScrobbles(request: request)
    }

    // MARK: Refresh

    func refresh(request: Scrobble.Refresh.Request) {
        DDLogDebug("refresh")

        guard !isRefreshing else {
            DDLogDebug("Refresh already in progress; aborting")
            return
        }
        
        let request = Scrobble.SearchForNewScrobbles.Request(autoSubmit: true, delay: request.delay)
        searchForNewScrobbles(request: request)
    }

    // MARK: Search for new scrobbles
    
    func searchForNewScrobbles(request: Scrobble.SearchForNewScrobbles.Request) {
        DDLogDebug("Searching for songs that need to be scrobbled...")
        
        guard !isSearchingForScrobbles else {
            DDLogDebug("Already searching for scrobbles; Aborting")
            isSearchingForScrobbles = false
            return
        }
        
        isSearchingForScrobbles = true
        
        presenter?.presentSearchingForNewScrobbles()

        if request.delay {
            delay(seconds: 1) {
                self.doSearchForNewSongsToScrobble(request: request)
            }
        } else {
            doSearchForNewSongsToScrobble(request: request)
        }
    }
    
    private func doSearchForNewSongsToScrobble(request: Scrobble.SearchForNewScrobbles.Request) {
        worker.searchForNewSongsToScrobble() { songsToScrobble in
            let response = Scrobble.SearchForNewScrobbles.Response(songs: songsToScrobble)
            self.presenter?.presentSongsToScrobble(response: response)
            
            if request.autoSubmit && songsToScrobble.count > 0 {
                let request = Scrobble.SubmitScrobbles.Request()
                self.submitScrobbles(request: request)
            }
            
            self.isSearchingForScrobbles = false
        }
    }
    
    // MARK: Submit scrobbles
    
    func submitScrobbles(request: Scrobble.SubmitScrobbles.Request) {
        DDLogDebug("Submitting scrobbles...")
        
        guard !isSubmittingScrobbles else {
            DDLogDebug("Already submitting scrobbles; aborting")
            isSubmittingScrobbles = false
            return
        }
        
        isSubmittingScrobbles = true
        
        presenter?.presentSubmittingToLastFM()

        worker.submitUnscrobbledSongs() { updatedSongs, error in
            if let error = error as? LastFM.ErrorType, case LastFM.ErrorType.notSignedIn = error {
                self.presenter?.presentScrobbleFailedNotLoggedIn()
            } else {
                let response = Scrobble.SubmitScrobbles.Response(error: error)
                self.presenter?.presentScrobblingComplete(response: response)
            }

            self.isSubmittingScrobbles = false
        }
    }
    
    // MARK: Get Current User
    
    func getCurrentUser(request: Scrobble.GetCurrentUser.Request) {
        presenter?.presentCurrentUser(response: Scrobble.GetCurrentUser.Response(username: worker.currentUserName))
    }
    
    // MARK: Sign Out
    
    func signOut(request: Scrobble.SignOut.Request) {
        worker.signOut()
        
        let response = Scrobble.GetCurrentUser.Response(username: worker.currentUserName)
        presenter?.presentCurrentUser(response: response)
    }
}
