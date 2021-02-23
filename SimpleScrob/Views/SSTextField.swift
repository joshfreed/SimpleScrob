//
//  SSTextField.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/3/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import UIKit

@IBDesignable
class SSTextField: NibDesignable {
    @IBOutlet var label: UILabel!
    @IBOutlet var textField: UITextField!
    
    @IBInspectable var placeholder: String? {
        get {
            return textField.placeholder
        }
        set {
            label.text = newValue
            textField.placeholder = newValue
        }
    }
    
    override func awakeFromNib() {
        label.isHidden = true
        _ = textField.addBorder(edges: .bottom, color: UIColor.lightGray, thickness: 1)
    }
    
    override func prepareForInterfaceBuilder() {
        label.isHidden = true
        _ = textField.addBorder(edges: .bottom, color: UIColor.lightGray, thickness: 1)
    }
}
