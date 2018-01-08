//
//  ScrobbleView.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/5/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import UIKit

protocol ScrobbleViewDelegate: class {
    func retry()
    func signIn()
}

class ScrobbleView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var scrobbleCountLabel: UILabel!
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    weak var delegate: ScrobbleViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ScrobbleView", owner: self, options: nil)
        addSubview(contentView)
        contentView.jpfPinToSuperview()
        
        activityIndicator.startAnimating()
        
        resetUI()
        signInButton.isHidden = true
    }
    
    // User actions
    
    @IBAction func tappedRetry(_ sender: UIButton) {
        delegate?.retry()
    }
    
    @IBAction func tappedSignInButton(_ sender: UIButton) {
        delegate?.signIn()
    }
    
    // Stuff and whatnot
    
    private func resetUI() {
        statusLabel.isHidden = true
        activityIndicator.stopAnimating()
        doneLabel.isHidden = true
        scrobbleCountLabel.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
    }
    
    func displayFirstTimeView() {
        statusLabel.isHidden = false
        statusLabel.text = "Songs you listen to will be scrobbled next time you open the app."
        activityIndicator.stopAnimating()
    }
    
    func displayReadyToScrobble() {
        statusLabel.text = ""
    }
    
    func displaySearchingForNewScrobbles() {
        resetUI()
        statusLabel.isHidden = false
        statusLabel.text = "Searching for new scrobbles..."
        activityIndicator.startAnimating()
    }
    
    func displaySongsToScrobble(viewModel: Scrobble.SearchForNewScrobbles.ViewModel) {
        scrobbleCountLabel.isHidden = false
        statusLabel.isHidden = true
        activityIndicator.stopAnimating()
        
        let message = viewModel.numberOfSongs == 1 ? "Found 1 new scrobble." : "Found \(viewModel.numberOfSongs) new scrobbles."
        scrobbleCountLabel.text = message
    }
    
    func displayNoSongsToScrobble() {
        resetUI()
        statusLabel.isHidden = false
        statusLabel.text = "No songs to scrobble."
        activityIndicator.stopAnimating()
    }
    
    func displaySubmittingToLastFM() {
        retryButton.isHidden = true
        errorLabel.isHidden = true
        statusLabel.isHidden = false
        activityIndicator.startAnimating()
        statusLabel.text = "Submitting to last.fm..."
    }
    
    func displayScrobblingComplete(viewModel: Scrobble.SubmitScrobbles.ViewModel) {
        statusLabel.isHidden = false
        
        if let error = viewModel.error {
            activityIndicator.stopAnimating()
            errorLabel.text = error
            retryButton.isHidden = false
            errorLabel.isHidden = false
        } else {
            doneLabel.isHidden = false
            activityIndicator.stopAnimating()
        }
    }
    
    func displayNotSignedIn() {
        signInButton.isHidden = false
        signInButton.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.signInButton.alpha = 1
        })
    }
    
    func displaySignedIn() {
        signInButton.isHidden = true
    }
}
