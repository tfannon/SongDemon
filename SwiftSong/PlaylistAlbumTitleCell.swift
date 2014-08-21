//
//  PlaylistAlbumTitleCell.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/20/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class PlaylistAlbumTitleCell: UITableViewCell {
    
    @IBOutlet var lblArtist: UILabel!
    @IBOutlet var lblAlbum: UILabel!
    @IBOutlet var imgArtwork: UIImageView!

    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
