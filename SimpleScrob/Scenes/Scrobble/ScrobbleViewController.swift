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

protocol ScrobbleDisplayLogic: class {
    func displayFirstTimeView(viewModel: Scrobble.Refresh.ViewModel)
    func displayReadyToScrobble(viewModel: Scrobble.Refresh.ViewModel)
    func displayAuthorizationPrimer()
    func displayAuthorizationDenied()
    func displaySearchingForNewScrobbles()
    func displaySongsToScrobble(viewModel: Scrobble.SearchForNewScrobbles.ViewModel)
    func displayNoSongsToScrobble()
    func displaySubmittingToLastFM()
    func displayScrobblingComplete(viewModel: Scrobble.SubmitScrobbles.ViewModel)
    func displayCurrentUser(viewModel: Scrobble.GetCurrentUser.ViewModel)
}

class ScrobbleViewController: UIViewController, ScrobbleDisplayLogic {
    var interactor: ScrobbleBusinessLogic?
    var router: (NSObjectProtocol & ScrobbleRoutingLogic & ScrobbleDataPassing)?
    
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var currentUserButton: UIButton!
    @IBOutlet weak var viewScrobblesButton: UIButton!
    @IBOutlet weak var viewScrobblesHitAreaButton: UIButton!
    
    @IBOutlet var scrobbleView: ScrobbleView!
    @IBOutlet var mediaAuthPrimerView: MediaAuthPrimerView!
    
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
            mediaLibrary: appDelegate.mediaLibrary,
            worker: ScrobbleWorker(
                database: appDelegate.database,
                songScanner: appDelegate.songScanner,
                scrobbleService: appDelegate.scrobbleService,
                connectivity: AlamofireConnectivity()
            )
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
        
        if !UserDefaults.standard.bool(forKey: "isTest") {
            NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .UIApplicationDidBecomeActive, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(userSignedIn), name: .signedIn, object: nil)
        }
        
        currentUserButton.isHidden = true

        mediaAuthPrimerView.delegate = self
        scrobbleView.delegate = self
    }

    private func showContent(view: UIView) {
        scrobbleView.removeFromSuperview()
        mediaAuthPrimerView.removeFromSuperview()
        
        contentContainer.addSubview(view)
        view.jpfPinToSuperview()        
    }
    
    // MARK: Events
    
    @objc func userSignedIn() {
        interactor?.getCurrentUser()
        
        let request = Scrobble.SubmitScrobbles.Request()
        interactor?.submitScrobbles(request: request)
    }
    
    @IBAction func unwindToScrobble(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: Refresh

    @objc func refresh() {
        let request = Scrobble.Refresh.Request()
        interactor?.refresh(request: request)
    }

    func displayFirstTimeView(viewModel: Scrobble.Refresh.ViewModel) {
        showContent(view: scrobbleView)
        scrobbleView.displayFirstTimeView()
        viewScrobblesButton.isHidden = false
        viewScrobblesHitAreaButton.isHidden = false
    }
    
    func displayReadyToScrobble(viewModel: Scrobble.Refresh.ViewModel) {
        DDLogVerbose("ScrobbleViewController::displayReadyToScrobble")
        showContent(view: scrobbleView)
        scrobbleView.displayReadyToScrobble()
        viewScrobblesButton.isHidden = false
        viewScrobblesHitAreaButton.isHidden = false
    }

    func displayAuthorizationPrimer() {
        showContent(view: mediaAuthPrimerView)
        viewScrobblesButton.isHidden = true
        viewScrobblesHitAreaButton.isHidden = true
    }
    
    func displayAuthorizationDenied() {
        
    }
    
    // MARK: Search for new scrobbles
    
    func displaySearchingForNewScrobbles() {
        scrobbleView.displaySearchingForNewScrobbles()
    }
    
    func displaySongsToScrobble(viewModel: Scrobble.SearchForNewScrobbles.ViewModel) {
        scrobbleView.displaySongsToScrobble(viewModel: viewModel)
    }
    
    func displayNoSongsToScrobble() {
        DDLogVerbose("ScrobbleViewController::displayNoSongsToScrobble")
        scrobbleView.displayNoSongsToScrobble()
    }
    
    // MARK: Submit scrobbles
    
    func displaySubmittingToLastFM() {
        scrobbleView.displaySubmittingToLastFM()
    }
    
    func displayScrobblingComplete(viewModel: Scrobble.SubmitScrobbles.ViewModel) {
        scrobbleView.displayScrobblingComplete(viewModel: viewModel)
    }
    
    // MARK: Get current user
    
    var isLoggedIn = false
    
    func displayCurrentUser(viewModel: Scrobble.GetCurrentUser.ViewModel) {
        if let _ = viewModel.username {
            isLoggedIn = true
            currentUserButton.isHidden = false
            scrobbleView.displaySignedIn()
        } else {
            isLoggedIn = false
            currentUserButton.isHidden = true
            scrobbleView.displayNotSignedIn()
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
}

extension ScrobbleViewController: MediaAuthPrimerViewDelegate {
    func requestAuthorization() {
        interactor?.requestMediaLibraryAuthorization()
    }
}

extension ScrobbleViewController: ScrobbleViewDelegate {
    func retry() {
        let request = Scrobble.SubmitScrobbles.Request()
        interactor?.submitScrobbles(request: request)
    }

    func signIn() {
        performSegue(withIdentifier: "SignIn", sender: nil)
    }
}
