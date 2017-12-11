//
//  PartyCell.swift
//  Inclusive
//
//  Created by Sam Furlong on 11/25/17.
//  Copyright © 2017 Sam Furlong. All rights reserved.
//

import UIKit

class PartyCell: UITableViewCell {

    @IBOutlet weak var Analytics: UIButton!
    @IBOutlet weak var EditParty: UIButton!
    
    @IBOutlet weak var VerifyParty: UIButton!
    @IBOutlet weak var PartyName: UILabel!
    @IBOutlet weak var DeletePartyButton: UIButton!
    
    @IBOutlet weak var StartTimeEndTime: UILabel!
    @IBOutlet weak var StartDate: UILabel!
    
    @IBOutlet weak var AddBouncers: UIButton!
    @IBOutlet weak var RSVP: UILabel!
  
    @IBOutlet weak var PartyImage: UIImageView!
    
    @IBOutlet weak var Invite: UIButton!
    @IBOutlet weak var Location: UITextView!
    /*
     // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
  

}
