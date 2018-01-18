//
//  ReadyToScrobbleViewController.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/12/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import UIKit
import CocoaLumberjack

class ReadyToScrobbleViewController: UIViewController {
    var songScanner: SongScanner!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        songScanner = appDelegate.songScanner
        songScanner.initializeSongDatabase()
    }
    
    @objc func applicationWillEnterForeground() {
        DDLogVerbose("ReadyToScrobbleViewController::applicationWillEnterForeground")
        
        if songScanner.isInitialized {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: "ScrobbleViewController")
            present(vc, animated: false) {
                NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
            }
        }
    }
}
