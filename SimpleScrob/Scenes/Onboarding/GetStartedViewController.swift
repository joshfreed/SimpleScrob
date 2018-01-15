//
//  GetStartedViewController.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/12/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import UIKit

class GetStartedViewController: UIViewController {
    var mediaLibrary: MediaLibrary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        mediaLibrary = appDelegate.mediaLibrary
    }

    @IBAction func getStarted(_ sender: PrimaryButton) {
        if mediaLibrary.isAuthorized() {
            performSegue(withIdentifier: "SignIn", sender: nil)
        } else if mediaLibrary.authorizationDenied() {
            performSegue(withIdentifier: "MediaAuthDenied", sender: nil)
        } else {
            performSegue(withIdentifier: "RequestMediaAccess", sender: nil)
        }
    }
}
