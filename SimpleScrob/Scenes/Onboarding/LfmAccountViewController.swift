//
//  LfmAccountViewController.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/12/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import UIKit
import SafariServices

class LfmAccountViewController: UIViewController, SignInViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tappedCreateAccount(_ sender: UIButton) {
        let url = URL(string: "https://www.last.fm/join")!
        let sfv = SFSafariViewController(url: url)
        sfv.modalPresentationStyle = .overFullScreen
        present(sfv, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignIn" {
            let vc = segue.destination as! SignInViewController
            vc.delegate = self
        }
    }

    // MARK: - SignInViewControllerDelegate
    
    func loginSuccess() {
        performSegue(withIdentifier: "ReadyToScrobble", sender: self)
    }
}
