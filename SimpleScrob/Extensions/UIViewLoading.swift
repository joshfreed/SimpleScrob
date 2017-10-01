//
//  UIViewLoading.swift
//  SimpleScrob
//
//  Created by Josh Freed on 9/29/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import UIKit

protocol UIViewLoading {}
extension UIView : UIViewLoading {}

extension UIViewLoading where Self : UIView {
    static func loadFromNib() -> Self {
        let nibName = "\(self)"
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! Self
    }
}
