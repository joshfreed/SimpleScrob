//
//  MediaAuthDeniedViewController.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/12/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import UIKit

class MediaAuthDeniedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func openSettings(_ sender: UIButton) {
        let settingUrl = URL(string: UIApplication.openSettingsURLString)!
        
        UIApplication.shared.open(settingUrl) { isOpen in
            if !isOpen {
                debugPrint("Error opening:\(settingUrl.absoluteString)")
            }
        }
    }
}
