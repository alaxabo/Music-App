//
//  SongTableCell.swift
//  MusicApp
//
//  Created by Alaxabo on 6/21/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import UIKit

class SongTableCell: UITableViewCell {

    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artworkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
