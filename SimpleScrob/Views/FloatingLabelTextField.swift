//
//  FloatingLabelTextField.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/3/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import UIKit

@IBDesignable
class FloatingLabelTextField: UITextField {
    let label = UILabel()
    
    override var placeholder: String? {
        didSet {
            label.text = placeholder
        }
    }
    
    var placeholderColor: UIColor = UIColor.gray.withAlphaComponent(0.7)
    
    private var labelShownConstraint: NSLayoutConstraint?
    private var labelHiddenConstraint: NSLayoutConstraint?
    private var inactiveBorder: UIView?
    private var activeBorder: UIView?
    private var errorBorder: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        borderStyle = .none
        
        inactiveBorder = addBorder(edges: .bottom, color: placeholderColor, thickness: 1).first
        activeBorder = addBorder(edges: .bottom, color: .black, thickness: 1).first
        errorBorder = addBorder(edges: .bottom, color: .red, thickness: 1).first
        
        showInactiveBorder()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = placeholderColor
        label.text = placeholder
        addSubview(label)
        labelShownConstraint = label.bottomAnchor.constraint(equalTo: topAnchor, constant: 0)
        labelHiddenConstraint = label.centerYAnchor.constraint(equalTo: centerYAnchor)
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true

        label.alpha = 0
        labelHiddenConstraint?.isActive = true
        
        updateFloatingLabel()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateFloatingLabel()
    }
    
    @objc func textFieldDidBeginEditing() {
        showActiveBorder()
    }
    
    @objc func textFieldDidEndEditing() {
        showInactiveBorder()
    }
    
    func updateFloatingLabel() {
        if let text = text, !text.isEmpty {
            self.labelHiddenConstraint?.isActive = false
            self.labelShownConstraint?.isActive = true
            
            UIView.animate(withDuration: 0.25) {
                self.label.alpha = 1
                self.layoutIfNeeded()
            }
        } else {
            self.labelShownConstraint?.isActive = false
            self.labelHiddenConstraint?.isActive = true
            
            UIView.animate(withDuration: 0.25) {
                self.label.alpha = 0
                self.layoutIfNeeded()
            }
        }
    }
    
    func displayInvalid() {
        showErrorBorder()
    }
    
    func displayValid() {
        showInactiveBorder()
    }
    
    // Border Helpers
    
    private func showErrorBorder() {
        errorBorder?.isHidden = false
        activeBorder?.isHidden = true
        inactiveBorder?.isHidden = true
    }
    
    private func showActiveBorder() {
        activeBorder?.isHidden = false
        inactiveBorder?.isHidden = true
        errorBorder?.isHidden = true
    }
    
    private func showInactiveBorder() {
        errorBorder?.isHidden = true
        activeBorder?.isHidden = true
        inactiveBorder?.isHidden = false
    }
}
