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
    
    var expanded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(scrobble: PlayedSong) {
        selectionStyle = .none
        
        expanded = false
        detailsHeightConstraint.isActive = true
        
        artistLabel.text = scrobble.track
        albumLabel.text = scrobble.artist
        trackLabel.text = scrobble.album
        artworkImageView.image = scrobble.artwork?.image(at: CGSize(width: 64, height: 64))
        datePlayedLabel.text = scrobble.date.shortTimeAgoSinceNow
        
        switch scrobble.status {
        case .scrobbled:
            statusImageView.image = #imageLiteral(resourceName: "scrobbled")
            statusLabel.text = "Scrobbled!"
//            statusLabel.textColor = .green
            statusLabel.textColor = UIColor(red: 46/255, green: 162/255, blue: 66/255, alpha: 1)
        case .failed:
            statusImageView.image = #imageLiteral(resourceName: "failed")
            statusLabel.text = "Error"
            statusLabel.textColor = .red
        case .notScrobbled:
            statusImageView.image = #imageLiteral(resourceName: "not-scrobbled")
            statusLabel.text = "Not Scrobbled"
            statusLabel.textColor = .lightGray
        case .ignored:
            statusImageView.image = #imageLiteral(resourceName: "not-scrobbled")
            statusLabel.text = "Ignored"
            statusLabel.textColor = .yellow
        }
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

