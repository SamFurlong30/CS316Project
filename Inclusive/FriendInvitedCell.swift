//
//  FriendInvitedCell.swift
//  Inclusive
//
//  Created by Sam Furlong on 11/27/17.
//  Copyright © 2017 Sam Furlong. All rights reserved.
//

import UIKit

class FriendInvitedCell: UITableViewCell {

    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var DeleteInviteAction: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
