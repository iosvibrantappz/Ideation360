//
//  CampaignsCell.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 19/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit

class CampaignsCell: UITableViewCell {
    
    @IBOutlet var name_lbl: UILabel!
    @IBOutlet var duration: UILabel!
    @IBOutlet var numIdeas: UILabel!
    
    @IBOutlet var seprator_lbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
