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
import os.log
import JFLib

protocol ScrobbleBusinessLogic {
    func refresh(request: Scrobble.Refresh.Request)
    func requestMediaLibraryAuthorization()
    func initializeMusicLibrary(request: Scrobble.InitializeMusicLibrary.Request)
    func searchForNewScrobbles(request: Scrobble.SearchForNewScrobbles.Request)
    func submitScrobbles(request: Scrobble.SubmitScrobbles.Request)
    func getCurrentUser()
    func signOut(request: Scrobble.SignOut.Request)
}

protocol ScrobbleDataStore {
    
}

class ScrobbleInteractor: ScrobbleBusinessLogic, ScrobbleDataStore {
    var presenter: ScrobblePresentationLogic?
    let logger = OSLog(subsystem: "com.joshfreed.SimpleScrob", category: "ScrobbleInteractor")
    let mediaLibrary: MediaLibrary
    let worker: ScrobbleWorker
    let songScanner: SongScanner

    var playedSongs: [PlayedSong] = []
    
    init(
        mediaLibrary: MediaLibrary,
        worker: ScrobbleWorker,
        songScanner: SongScanner
    ) {
        self.mediaLibrary = mediaLibrary
        self.worker = worker
        self.songScanner = songScanner
    }
    
    private func presentMainScreen() {
        if mediaLibrary.isAuthorized() {
            os_log("presentAuthorized", log: logger, type: .debug)
            let response = Scrobble.Refresh.Response(firstTime: !songScanner.isInitialized)
            presenter?.presentAuthorized(response: response)
        } else if mediaLibrary.authorizationDenied() {
            os_log("presentAuthorizationDenied", log: logger, type: .debug)
            presenter?.presentAuthorizationDenied()
        } else {
            os_log("presentAuthorizationPrimer", log: logger, type: .debug)
            presenter?.presentAuthorizationPrimer()
        }
    }
    
    // MARK: Refresh

    func refresh(request: Scrobble.Refresh.Request) {
        os_log("refresh", log: logger, type: .debug)
        
        presentMainScreen()
    }
    
    // MARK: Request media library authorization
    
    func requestMediaLibraryAuthorization() {
        mediaLibrary.requestAuthorization {
            self.presentMainScreen()
        }        
    }
    
    // MARK: Initialize music library
    
    func initializeMusicLibrary(request: Scrobble.InitializeMusicLibrary.Request) {
        presenter?.presentScanningMusicLibrary()
        
        DispatchQueue.global(qos: .background).async {
            self.songScanner.initializeSongDatabase()
            
            DispatchQueue.main.sync {
                self.presenter?.presentCurrentUser(response: Scrobble.GetCurrentUser.Response(user: self.worker.currentUser))
                self.presenter?.presentLibraryScanComplete(response: Scrobble.InitializeMusicLibrary.Response())
            }
        }
    }
    
    // MARK: Search for new scrobbles
    
    func searchForNewScrobbles(request: Scrobble.SearchForNewScrobbles.Request) {
        presenter?.presentCurrentUser(response: Scrobble.GetCurrentUser.Response(user: self.worker.currentUser))
        presenter?.presentSearchingForNewScrobbles()

        worker.searchForNewSongsToScrobble() { playedSongs in
            self.playedSongs = playedSongs
            let response = Scrobble.SearchForNewScrobbles.Response(songs: self.playedSongs)
            self.presenter?.presentSongsToScrobble(response: response)
        }
    }
    
    // MARK: Submit scrobbles
    
    func submitScrobbles(request: Scrobble.SubmitScrobbles.Request) {
        guard playedSongs.count > 0 else {
            return
        }
        
        presenter?.presentSubmittingToLastFM()

        delay(seconds: 0.5) {
            self.worker.submit(songs: self.playedSongs) { error in
                let response = Scrobble.SubmitScrobbles.Response(error: error)
                self.presenter?.presentScrobblingComplete(response: response)
            }
        }
    }
    
    // MARK: Get current user
    
    func getCurrentUser() {
        let response = Scrobble.GetCurrentUser.Response(user: worker.currentUser)
        presenter?.presentCurrentUser(response: response)
        
        if worker.currentUser != nil && playedSongs.count > 0 {
            let request = Scrobble.SubmitScrobbles.Request()
            submitScrobbles(request: request)
        }
    }
    
    // MARK: Sign Out
    
    func signOut(request: Scrobble.SignOut.Request) {
        worker.signOut()
        
        let response = Scrobble.GetCurrentUser.Response(user: worker.currentUser)
        presenter?.presentCurrentUser(response: response)
    }
}
