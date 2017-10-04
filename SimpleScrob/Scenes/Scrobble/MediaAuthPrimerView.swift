//
//  MediaAuthPrimerView.swift
//  SimpleScrob
//
//  Created by Josh Freed on 9/29/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import UIKit
import MediaPlayer

protocol MediaAuthPrimerViewDelegate: class {
    func authorizationWasGranted()
    func authorizationWasDenied()
}

class MediaAuthPrimerView: UIView {
    @IBOutlet weak var okayButton: UIButton!
    
    weak var delegate: MediaAuthPrimerViewDelegate?
    
    override func awakeFromNib() {
        okayButton.layer.cornerRadius = 5
    }
    
    @IBAction func tappedOkay(_ sender: UIButton) {
        MPMediaLibrary.requestAuthorization { status in
            switch status {
            case .notDetermined: break
            case .denied: self.delegate?.authorizationWasDenied()
            case .restricted: break
            case .authorized: self.delegate?.authorizationWasGranted()
            }
        }
    }
}
