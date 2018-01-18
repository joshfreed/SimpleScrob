//
//  FadeInSegue.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/18/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import UIKit

class FadeInSegue: UIStoryboardSegue {
    override func perform() {
        let sourceView = source.view!
        let destView = destination.view!
        let window = UIApplication.shared.keyWindow
        
        destView.alpha = 0
        window?.insertSubview(destView, aboveSubview: sourceView)

        UIView.animate(withDuration: 0.35, animations: {
            destView.alpha = 1
        }) { _ in
            self.source.present(self.destination, animated: false, completion: nil)
        }
    }
}
