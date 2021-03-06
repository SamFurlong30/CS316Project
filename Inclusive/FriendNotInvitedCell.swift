//
//  FriendCell.swift
//  Inclusive
//
//  Created by Sam Furlong on 11/27/17.
//  Copyright © 2017 Sam Furlong. All rights reserved.
//

import UIKit

class FriendNotInvitedCell: UITableViewCell {
    @IBOutlet weak var ProfilePic: UIImageView!
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var AddToListAction: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
