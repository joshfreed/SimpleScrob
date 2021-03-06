//
//  ViewExtensions.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/5/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import UIKit

extension UIView {
    func jpfPinToSuperview() {
        guard let parent = superview else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }
    
    func jpfPinToSuperview(padding: CGFloat) {
        guard let parent = superview else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: padding).isActive = true
        trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -padding).isActive = true
        topAnchor.constraint(equalTo: parent.topAnchor, constant: padding).isActive = true
        bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -padding).isActive = true
    }
}
