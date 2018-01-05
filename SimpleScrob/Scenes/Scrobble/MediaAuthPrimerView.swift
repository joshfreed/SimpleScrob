//
//  MediaAuthPrimerView.swift
//  SimpleScrob
//
//  Created by Josh Freed on 9/29/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import UIKit
import MediaPlayer

protocol MediaAuthPrimerViewDelegate: class {
    func requestAuthorization()
}

class MediaAuthPrimerView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var okayButton: UIButton!
    
    weak var delegate: MediaAuthPrimerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MediaAuthPrimerView", owner: self, options: nil)
        addSubview(contentView)
        contentView.jpfPinToSuperview()
        
        okayButton.layer.cornerRadius = 5
    }

    @IBAction func tappedOkay(_ sender: UIButton) {
        delegate?.requestAuthorization()
    }
}
