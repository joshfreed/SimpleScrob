//
//  PrimaryButton.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/12/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import UIKit

@IBDesignable
class PrimaryButton: UIButton {
    let defaultFontSize: CGFloat = 21
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
    
    private func setup() {
        backgroundColor = #colorLiteral(red: 0.1254901961, green: 0.5058823529, blue: 0.7647058824, alpha: 1)
        tintColor = .white
        layer.cornerRadius = 5
        titleLabel?.font = UIFont.systemFont(ofSize: defaultFontSize, weight: UIFont.Weight.medium)
    }
}
