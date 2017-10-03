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

protocol ScrobbleDisplayLogic: class {
    func displayAuthorized(viewModel: Scrobble.Refresh.ViewModel)
    func displayAuthorizationPrimer()
    func displayAuthorizationDenied()
    func displayScanningMusicLibrary()
    func displayLibraryScanComplete(viewModel: Scrobble.InitializeMusicLibrary.ViewModel)
    func displaySearchingForNewScrobbles()
    func displaySongsToScrobble(viewModel: Scrobble.SearchForNewScrobbles.ViewModel)
    func displayNoSongsToScrobble()
    func displaySubmittingToLastFM()
    func displayScrobblingComplete()
    func displayCurrentUser(viewModel: Scrobble.GetCurrentUser.ViewModel)
}

class ScrobbleViewController: UIViewController, ScrobbleDisplayLogic {
    var interactor: ScrobbleBusinessLogic?
    var router: (NSObjectProtocol & ScrobbleRoutingLogic & ScrobbleDataPassing)?
    
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var currentUserView: UIView!
    @IBOutlet weak var currentUserLabel: UILabel!
    @IBOutlet weak var scrobbleCountLabel: UILabel!
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var viewScrobblesButton: UIButton!
    
    var mediaAuthPrimerView: MediaAuthPrimerView?
    
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewController = self
        let interactor = ScrobbleInteractor(
            mediaLibrary: MediaLibrary.shared,
            lastFM: LastFM.shared,
            database: appDelegate.database,
            songScanner: appDelegate.songScanner
        )
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userSignedIn), name: .signedIn, object: nil)
        
        mediaAuthPrimerView = MediaAuthPrimerView.loadFromNib()
        mediaAuthPrimerView!.delegate = self
        contentStackView.addArrangedSubview(mediaAuthPrimerView!)
        
//        refresh()
    }
    
    @objc func applicationDidBecomeActive() {
        refresh()
    }
    
    @objc func userSignedIn() {
        interactor?.getCurrentUser()
    }
    
    @IBAction func unwindToScrobble(segue: UIStoryboardSegue) {
        
    }

    // MARK: Refresh

    //@IBOutlet weak var nameTextField: UITextField!

    func refresh() {
        statusLabel.isHidden = true
        activityIndicator.stopAnimating()
        signInButton.isHidden = true
        currentUserView.isHidden = true
        mediaAuthPrimerView?.isHidden = true
        doneLabel.isHidden = true
        viewScrobblesButton.isHidden = true
        scrobbleCountLabel.isHidden = true
        
        let request = Scrobble.Refresh.Request()
        interactor?.refresh(request: request)
    }
    
    func displayAuthorized(viewModel: Scrobble.Refresh.ViewModel) {
        if viewModel.firstTime {
            let request = Scrobble.InitializeMusicLibrary.Request()
            interactor?.initializeMusicLibrary(request: request)
        } else {
            let request = Scrobble.SearchForNewScrobbles.Request()
            interactor?.searchForNewScrobbles(request: request)
        }
    }
    
    func displayAuthorizationPrimer() {
        mediaAuthPrimerView?.isHidden = false
    }
    
    func displayAuthorizationDenied() {
        
    }
    
    // MARK: Initialize music library
    
    func displayScanningMusicLibrary() {
        statusLabel.isHidden = false
        statusLabel.text = "Scanning your music library..."
        activityIndicator.startAnimating()
    }
    
    func displayLibraryScanComplete(viewModel: Scrobble.InitializeMusicLibrary.ViewModel) {
        statusLabel.isHidden = false
        statusLabel.text = "Songs you listen to will be scrobbled next time you open the app."
        activityIndicator.stopAnimating()
    }
    
    // MARK: Search for new scrobbles
    
    func displaySearchingForNewScrobbles() {
        statusLabel.isHidden = false
        statusLabel.text = "Searching for new scrobbles..."
        activityIndicator.startAnimating()
    }
    
    func displaySongsToScrobble(viewModel: Scrobble.SearchForNewScrobbles.ViewModel) {
        scrobbleCountLabel.isHidden = false
        statusLabel.isHidden = true
        activityIndicator.stopAnimating()
        
        let message = viewModel.songs.count == 1 ? "Found 1 new scrobble." : "Found \(viewModel.songs.count) new scrobbles."
        scrobbleCountLabel.text = message
        
        let request = Scrobble.SubmitScrobbles.Request(songs: viewModel.songs)
        interactor?.submitScrobbles(request: request)
    }
    
    func displayNoSongsToScrobble() {
        statusLabel.text = "No songs to scrobble."
        activityIndicator.stopAnimating()
    }
    
    // MARK: Submit scrobbles
    
    func displaySubmittingToLastFM() {
        statusLabel.isHidden = false
        activityIndicator.startAnimating()
        statusLabel.text = "Submitting to last.fm..."
    }
    
    func displayScrobblingComplete() {
        statusLabel.isHidden = true
        doneLabel.isHidden = false
        viewScrobblesButton.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    // MARK: Get current user
    
    func displayCurrentUser(viewModel: Scrobble.GetCurrentUser.ViewModel) {
        if let username = viewModel.username {
            currentUserView.isHidden = false
            currentUserLabel.text = username
            signInButton.isHidden = true
        } else {
            currentUserView.isHidden = true
            signInButton.isHidden = false
            signInButton.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.signInButton.alpha = 1
            })
        }
    }
    
    // MARK: Sign In
    
    @IBAction func tappedSignIn(_ sender: UIButton) {
    }
    
    // MARK: Sign Out
    
    @IBAction func tappedSignOut(_ sender: UIButton) {
        
    }
    
    // MARK: View scrobbles
    
    @IBAction func tappedViewScrobbles(_ sender: UIButton) {
    }    
}

extension ScrobbleViewController: MediaAuthPrimerViewDelegate {
    func authorizationWasGranted() {
        refresh()
    }
    
    func authorizationWasDenied() {
        refresh()
    }
}
