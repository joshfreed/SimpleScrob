//
//  ReadyToScrobbleViewController.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/12/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import UIKit

class ReadyToScrobbleViewController: UIViewController {
    var songScanner: SongScanner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        songScanner = appDelegate.songScanner
        songScanner.initializeSongDatabase()
    }
}
