//
//  ScrobblePresenter.swift
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

protocol ScrobblePresentationLogic {
    func presentAuthorized(response: Scrobble.Refresh.Response)
    func presentAuthorizationPrimer()
    func presentAuthorizationDenied()
    func presentScanningMusicLibrary()
    func presentLibraryScanComplete(response: Scrobble.InitializeMusicLibrary.Response)
    func presentSearchingForNewScrobbles()
    func presentSongsToScrobble(response: Scrobble.SearchForNewScrobbles.Response)
    func presentSubmittingToLastFM()
    func presentScrobblingComplete()
    func presentCurrentUser(response: Scrobble.GetCurrentUser.Response)
}

class ScrobblePresenter: ScrobblePresentationLogic {
    weak var viewController: ScrobbleDisplayLogic?

    // MARK: Refresh

    func presentAuthorized(response: Scrobble.Refresh.Response) {
        let viewModel = Scrobble.Refresh.ViewModel(firstTime: response.firstTime)
        viewController?.displayAuthorized(viewModel: viewModel)
    }
    
    func presentAuthorizationPrimer() {
        viewController?.displayAuthorizationPrimer()
    }
    
    func presentAuthorizationDenied() {
        viewController?.displayAuthorizationDenied()
    }
    
    // MARK: Initialize music library
    
    func presentScanningMusicLibrary() {
        viewController?.displayScanningMusicLibrary()
    }
    
    func presentLibraryScanComplete(response: Scrobble.InitializeMusicLibrary.Response) {
        let viewModel = Scrobble.InitializeMusicLibrary.ViewModel()
        viewController?.displayLibraryScanComplete(viewModel: viewModel)
    }
    
    // MARK: Search for new scrobbles
    
    func presentSearchingForNewScrobbles() {
        viewController?.displaySearchingForNewScrobbles()
    }
    
    func presentSongsToScrobble(response: Scrobble.SearchForNewScrobbles.Response) {
        guard response.songs.count > 0 else {
            viewController?.displayNoSongsToScrobble()
            return
        }

        let viewModel = Scrobble.SearchForNewScrobbles.ViewModel(songs: response.songs)
        viewController?.displaySongsToScrobble(viewModel: viewModel)
    }
    
    // MARK: Submit scrobbles
    
    func presentSubmittingToLastFM() {
        viewController?.displaySubmittingToLastFM()
    }
    
    func presentScrobblingComplete() {
        viewController?.displayScrobblingComplete()
    }
    
    // MARK: Get current user
    
    func presentCurrentUser(response: Scrobble.GetCurrentUser.Response) {
        let viewModel = Scrobble.GetCurrentUser.ViewModel(username: currentUserText(currentUserName: response.user?.username))
        viewController?.displayCurrentUser(viewModel: viewModel)
    }

    // MARK: Helpers
    
    private func currentUserText(currentUserName: String?) -> String? {
        guard let currentUserName = currentUserName else {
            return nil
        }
        
        return "Signed in as \(currentUserName)"
    }
}
