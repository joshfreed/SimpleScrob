//
//  SongCell.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/8/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import UIKit

class SongCell: UITableViewCell {
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var datePlayedLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet var detailsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullDateLabel: UILabel!
    
    var expanded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(scrobble: ViewScrobbles.DisplayedScrobble) {
        selectionStyle = .none
        
        expanded = false
        detailsHeightConstraint.isActive = true
        
        artistLabel.text = scrobble.track
        albumLabel.text = scrobble.artist
        trackLabel.text = scrobble.album
        artworkImageView.image = scrobble.artwork
        datePlayedLabel.text = scrobble.datePlayed
        statusLabel.text = scrobble.statusMessage
        statusLabel.textColor = scrobble.statusColor
        statusImageView.image = UIImage(named: scrobble.statusImageName)
        fullDateLabel.text = scrobble.fullDate
    }
    
    func expand() {
        expanded = true
        
        detailsHeightConstraint.isActive = false
        
        UIView.animate(withDuration: 0.25) {
            self.contentView.layoutIfNeeded()
        }
    }
    
    func collapse() {
        expanded = false
        
        detailsHeightConstraint.isActive = true
        
        UIView.animate(withDuration: 0.25) {
            self.contentView.layoutIfNeeded()
        }
    }
}

