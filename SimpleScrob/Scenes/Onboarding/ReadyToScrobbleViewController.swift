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
    lazy var mediaSource: MediaSource = Container.shared.mediaSource
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        mediaSource.initialize(completion: {})
    }
    
    @objc func applicationWillEnterForeground() {
        if mediaSource.isInitialized {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: "ScrobbleViewController")
            present(vc, animated: false) {
                NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
            }
        }
    }
}
