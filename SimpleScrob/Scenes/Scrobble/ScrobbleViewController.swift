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
    func displayScanningMusicLibrary()
    func displayLibraryScanComplete(viewModel: Scrobble.Refresh.ViewModel)
    func displaySearchingForNewScrobbles()
    func displayAuthorizationPrimer()
    func displayAuthorizationDenied()
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
        let viewController = self
        let interactor = ScrobbleInteractor(mediaLibrary: MediaLibrary.shared)
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
        
        mediaAuthPrimerView = MediaAuthPrimerView.loadFromNib()
        mediaAuthPrimerView!.delegate = self
        contentStackView.addArrangedSubview(mediaAuthPrimerView!)
        
        refresh()
    }
    
    @objc func applicationDidBecomeActive() {
        refresh()
    }

    // MARK: Refresh

    //@IBOutlet weak var nameTextField: UITextField!

    func refresh() {
        statusLabel.isHidden = true
        activityIndicator.stopAnimating()
        signInButton.isHidden = true
        currentUserView.isHidden = true
        mediaAuthPrimerView?.isHidden = true
        
        let request = Scrobble.Refresh.Request()
        interactor?.refresh(request: request)
    }
    
    func displayScanningMusicLibrary() {
        statusLabel.isHidden = false
        statusLabel.text = "Scanning your music library..."
        activityIndicator.startAnimating()
    }
    
    func displayLibraryScanComplete(viewModel: Scrobble.Refresh.ViewModel) {
        statusLabel.isHidden = false
        statusLabel.text = "Songs you listen to will be scrobbled next time you open the app."
        activityIndicator.stopAnimating()
        
        if let currentUserName = viewModel.currentUserName {
            currentUserView.isHidden = false
            currentUserLabel.text = currentUserName
        } else {
            signInButton.isHidden = false
        }
    }
    
    func displaySearchingForNewScrobbles() {
        statusLabel.isHidden = false
        statusLabel.text = "Searching for new scrobbles..."
        activityIndicator.startAnimating()
    }
    
    func displayAuthorizationPrimer() {
        mediaAuthPrimerView?.isHidden = false
    }
    
    func displayAuthorizationDenied() {
        
    }
    
    // MARK: Sign Out
    
    @IBAction func tappedSignOut(_ sender: UIButton) {
        
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
