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

protocol ScrobbleBusinessLogic {
    func refresh(request: Scrobble.Refresh.Request)
    func requestMediaLibraryAuthorization()
    func searchForNewScrobbles(request: Scrobble.SearchForNewScrobbles.Request)
    func submitScrobbles(request: Scrobble.SubmitScrobbles.Request)
    func getCurrentUser()
    func signOut(request: Scrobble.SignOut.Request)
}

protocol ScrobbleDataStore {
    
}

protocol ScrobbleMediaLibrary {
    func isAuthorized() -> Bool
    func authorizationDenied() -> Bool
    func requestAuthorization(complete: @escaping () -> ())
    func items(since date: Date?) -> [MediaItem]
}

protocol SongScanner {
    var isInitialized: Bool { get }
    func initializeSongDatabase()
    func searchForNewScrobbles() -> [PlayedSong]
}

class ScrobbleInteractor: ScrobbleBusinessLogic, ScrobbleDataStore {
    var presenter: ScrobblePresentationLogic?
    let mediaLibrary: ScrobbleMediaLibrary
    let worker: ScrobbleWorker

    private var playedSongs: [PlayedSong] = []
    private var isRefreshing = false
    private var isSearchingForScrobbles = false
    private var isRequestingAuthorization = false
    private var isSubmittingScrobbles = false
    
    init(
        mediaLibrary: ScrobbleMediaLibrary,
        worker: ScrobbleWorker
    ) {
        self.mediaLibrary = mediaLibrary
        self.worker = worker
    }
    
    private func presentMainScreen() {
        if mediaLibrary.isAuthorized() {
            presentAuthorized()
        } else if mediaLibrary.authorizationDenied() {
            DDLogDebug("presentAuthorizationDenied")
            presenter?.presentAuthorizationDenied()
            didEndRefreshing()
        } else {
            DDLogDebug("presentAuthorizationPrimer")
            presenter?.presentAuthorizationPrimer()
            didEndRefreshing()
        }
    }
    
    private func presentAuthorized() {
        DDLogDebug("presentAuthorized")
        
        presenter?.presentCurrentUser(response: Scrobble.GetCurrentUser.Response(username: worker.currentUserName))
        
        if worker.isFirstTime {
            DDLogDebug("Preparing for first time")
            worker.initializeMusicLibrary()
            presenter?.presentFirstTimeView(response: Scrobble.Refresh.Response())
            didEndRefreshing()
        } else {
            presenter?.presentReadyToScrobble(response: Scrobble.Refresh.Response())
            
            // Automatically search for new songs to scrobble
            let request = Scrobble.SearchForNewScrobbles.Request()
            searchForNewScrobbles(request: request)
        }
    }
    
    private func didEndRefreshing() {
        isRefreshing = false
        isSearchingForScrobbles = false
        isSubmittingScrobbles = false
    }

    // MARK: Refresh

    func refresh(request: Scrobble.Refresh.Request) {
        DDLogDebug("refresh")
        
        guard !isRequestingAuthorization else {
            DDLogVerbose("Refresh aborted: do not refresh while requesting authorization")
            return
        }
        
        guard !isRefreshing else {
            DDLogVerbose("Refresh already in progress; aborting")
            return
        }
        
        isRefreshing = true
        presentMainScreen()
    }
    
    // MARK: Request media library authorization
    
    func requestMediaLibraryAuthorization() {
        isRequestingAuthorization = true
        mediaLibrary.requestAuthorization {
            self.presentMainScreen()
            self.isRequestingAuthorization = false
        }        
    }

    // MARK: Search for new scrobbles
    
    func searchForNewScrobbles(request: Scrobble.SearchForNewScrobbles.Request) {
        DDLogVerbose("ScrobbleInteractor::searchForNewScrobbles")
        guard !isSearchingForScrobbles else {
            DDLogVerbose("Already searching for new scrobbles; Aborting")
            didEndRefreshing()
            return
        }
        
        isSearchingForScrobbles = true
        
        presenter?.presentSearchingForNewScrobbles()

        worker.searchForNewSongsToScrobble() { playedSongs in
            self.playedSongs = playedSongs

            let response = Scrobble.SearchForNewScrobbles.Response(songs: self.playedSongs)
            self.presenter?.presentSongsToScrobble(response: response)

            let request = Scrobble.SubmitScrobbles.Request()
            self.submitScrobbles(request: request)
        }
    }
    
    // MARK: Submit scrobbles
    
    func submitScrobbles(request: Scrobble.SubmitScrobbles.Request) {
        guard !isSubmittingScrobbles else {
            DDLogVerbose("Already submitting scrobbles; aborting")
            didEndRefreshing()
            return
        }
        guard playedSongs.count > 0 else {
            didEndRefreshing()
            return
        }
        
        isSubmittingScrobbles = true
        
        presenter?.presentSubmittingToLastFM()

        worker.submit(songs: self.playedSongs) { error in
            let response = Scrobble.SubmitScrobbles.Response(error: error)
            self.presenter?.presentScrobblingComplete(response: response)

            self.didEndRefreshing()
        }
    }
    
    // MARK: Get current user
    
    func getCurrentUser() {
        let response = Scrobble.GetCurrentUser.Response(username: worker.currentUserName)
        presenter?.presentCurrentUser(response: response)
    }
    
    // MARK: Sign Out
    
    func signOut(request: Scrobble.SignOut.Request) {
        worker.signOut()
        
        let response = Scrobble.GetCurrentUser.Response(username: worker.currentUserName)
        presenter?.presentCurrentUser(response: response)
    }
}
