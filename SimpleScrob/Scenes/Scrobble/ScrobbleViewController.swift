//
//  ScrobbleViewController.swift
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
import MediaPlayer
import StoreKit

protocol ScrobbleDisplayLogic: class {
    func displaySearchingForNewScrobbles()
    func displaySongsToScrobble(viewModel: Scrobble.SearchForNewScrobbles.ViewModel)
    func displayNoSongsToScrobble()
    func displaySubmittingToLastFM()
    func displayScrobblingComplete(viewModel: Scrobble.SubmitScrobbles.ViewModel)
    func displayScrobbleFailedNotSignedIn()
    func displayCurrentUser(viewModel: Scrobble.GetCurrentUser.ViewModel)
    func requestAppStoreReview()
}

class ScrobbleViewController: UIViewController, ScrobbleDisplayLogic {
    var interactor: ScrobbleBusinessLogic?
    var router: (NSObjectProtocol & ScrobbleRoutingLogic & ScrobbleDataPassing)?
    
    @IBOutlet weak var currentUserButton: UIButton!
    @IBOutlet weak var viewScrobblesButton: UIButton!
    @IBOutlet weak var viewScrobblesHitAreaButton: UIButton!
    
    @IBOutlet weak var scrobbleCountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    @IBOutlet weak var signInButton: UIButton!
    
    // MARK: Object lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Setup

    private func setup() {
        let viewController = self
        let worker = ScrobbleWorker(
            database: Container.shared.playedSongStore,
            mediaSource: Container.shared.mediaSource,
            scrobbleService: Container.shared.scrobbleService,
            connectivity: AlamofireConnectivity()
        )
        let interactor = ScrobbleInteractor(worker: worker)
        let presenter = ScrobblePresenter()
        let router = ScrobbleRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: Routing

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UserDefaults.standard.bool(forKey: "isTest") {
            NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(mediaLibraryDidChange), name: .MPMediaLibraryDidChange, object: nil)
        }

        scrobbleCountLabel.isHidden = true
        statusLabel.isHidden = true
        activityIndicator.stopAnimating()
        doneLabel.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        
        currentUserButton.isHidden = true
        signInButton.isHidden = true
        
        let request = Scrobble.GetCurrentUser.Request()
        interactor?.getCurrentUser(request: request)
    }
    
    // MARK: Events

    @IBAction func unwindToScrobble(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func tappedRetry(_ sender: UIButton) {
        let request = Scrobble.SubmitScrobbles.Request()
        interactor?.submitScrobbles(request: request)
    }
    
    @IBAction func tappedSignInButton(_ sender: UIButton) {
        performSegue(withIdentifier: "SignIn", sender: nil)
    }
    
    private func showScrobbleHistoryButton() {
        viewScrobblesButton.isHidden = false
        viewScrobblesHitAreaButton.isHidden = false
    }
    
    private func hideScrobbleHistoryButton() {
        viewScrobblesButton.isHidden = true
        viewScrobblesHitAreaButton.isHidden = true
    }
    
    @objc func applicationDidBecomeActive() {
        let request = Scrobble.Refresh.Request(delay: true)
        interactor?.refresh(request: request)
    }
    
    @objc func mediaLibraryDidChange() {
        DDLogInfo("MPMediaLibraryDidChange")
        DDLogDebug("Media library last modified at: \(MPMediaLibrary.default().lastModifiedDate.format(with: "yyyy-MM-dd HH:mm:ss"))")
    }
    
    // MARK: Search for new scrobbles
    
    func displaySearchingForNewScrobbles() {
        scrobbleCountLabel.isHidden = true
        statusLabel.isHidden = false
        activityIndicator.startAnimating()
        doneLabel.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        
        statusLabel.text = "Searching for new scrobbles..."
    }
    
    func displaySongsToScrobble(viewModel: Scrobble.SearchForNewScrobbles.ViewModel) {
        scrobbleCountLabel.isHidden = false
        statusLabel.isHidden = true
        activityIndicator.stopAnimating()
        doneLabel.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        
        let message = viewModel.numberOfSongs == 1 ? "Found 1 new scrobble." : "Found \(viewModel.numberOfSongs) new scrobbles."
        scrobbleCountLabel.text = message
    }
    
    func displayNoSongsToScrobble() {
        scrobbleCountLabel.isHidden = true
        statusLabel.isHidden = false
        activityIndicator.stopAnimating()
        doneLabel.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        
        statusLabel.text = "No songs to scrobble."
    }
    
    // MARK: Submit scrobbles
    
    func displaySubmittingToLastFM() {
        scrobbleCountLabel.isHidden = false
        statusLabel.isHidden = false
        activityIndicator.startAnimating()
        doneLabel.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        
        statusLabel.text = "Submitting to last.fm..."
    }
    
    func displayScrobblingComplete(viewModel: Scrobble.SubmitScrobbles.ViewModel) {
        scrobbleCountLabel.isHidden = false
        statusLabel.isHidden = false
        activityIndicator.stopAnimating()
        doneLabel.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        
        if let error = viewModel.error {
            errorLabel.text = error
            retryButton.isHidden = false
            errorLabel.isHidden = false
        } else {
            doneLabel.isHidden = false
        }
    }
    
    func displayScrobbleFailedNotSignedIn() {
        scrobbleCountLabel.isHidden = false
        statusLabel.isHidden = false
        activityIndicator.stopAnimating()
        doneLabel.isHidden = true
        errorLabel.isHidden = false
        retryButton.isHidden = true
        
        errorLabel.text = "You are not signed in to Last.fm"
    }
    
    // MARK: Get current user
    
    var isLoggedIn = false
    
    func displayCurrentUser(viewModel: Scrobble.GetCurrentUser.ViewModel) {
        if let _ = viewModel.username {
            isLoggedIn = true
            currentUserButton.isHidden = false
            signInButton.isHidden = true
        } else {
            isLoggedIn = false
            currentUserButton.isHidden = true
            signInButton.isHidden = false
            signInButton.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.signInButton.alpha = 1
            })
        }
    }
    
    // MARK: Sign Out
    
    @IBAction func tappedUserButton(_ sender: UIButton) {
        guard isLoggedIn else {
            return
        }
        
        displaySignOutConfirmation()
    }
    
    func displaySignOutConfirmation() {
        let activitySheet = UIAlertController(title: "Sign Out of Last.fm?", message: nil, preferredStyle: .actionSheet)
        activitySheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { action in
            self.signOut()
        }))
        activitySheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let popoverPresenter = activitySheet.popoverPresentationController
        popoverPresenter?.sourceView = currentUserButton
        popoverPresenter?.sourceRect = currentUserButton.bounds
        
        present(activitySheet, animated: true, completion: nil)
    }
    
    func signOut() {
        let request = Scrobble.SignOut.Request()
        interactor?.signOut(request: request)
    }
    
    // MARK: Request app store review
    
    func requestAppStoreReview() {
        let twoSecondsFromNow = DispatchTime.now() + 2.0
        DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) {
            SKStoreReviewController.requestReview()
        }        
    }
}

