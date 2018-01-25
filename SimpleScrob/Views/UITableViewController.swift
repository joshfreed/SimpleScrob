//
//  UITableViewController.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/25/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import UIKit

extension UITableViewController {
    func showEmptyMessage(_ message: String) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.systemFont(ofSize: 21)
        messageLabel.sizeToFit()
        
        container.addSubview(messageLabel)
        messageLabel.jpfPinToSuperview(padding: 32)
        
        tableView.backgroundView = container
    }
    
    func hideEmptyMessage() {
        tableView.backgroundView = nil
    }
}
