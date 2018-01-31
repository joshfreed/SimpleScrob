//
//  GrantAccessViewController.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/12/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import UIKit

class GrantAccessViewController: UIViewController {
    lazy var mediaLibrary: MediaLibrary = Container.shared.mediaLibrary
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tappedGrantAccess(_ sender: PrimaryButton) {
        mediaLibrary.requestAuthorization {
            if self.mediaLibrary.isAuthorized() {
                self.performSegue(withIdentifier: "AccountPrimer", sender: nil)
            } else if self.mediaLibrary.authorizationDenied() {
                self.performSegue(withIdentifier: "AuthorizationDenied", sender: nil)
            }
        }
    }
}
