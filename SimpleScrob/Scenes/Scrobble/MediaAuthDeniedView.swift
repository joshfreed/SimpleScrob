//
//  MediaAuthDeniedView.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/7/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import UIKit

protocol MediaAuthDeniedViewProtocol: class {
    func openSettings()
}

class MediaAuthDeniedView: UIView {
    @IBOutlet var contentView: UIView!
    
    weak var delegate: MediaAuthDeniedViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MediaAuthDeniedView", owner: self, options: nil)
        addSubview(contentView)
        contentView.jpfPinToSuperview()
    }
    
    @IBAction func openSettings(_ sender: UIButton) {
        delegate?.openSettings()
    }
}
