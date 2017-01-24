//
//  RatingCell.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 17/01/17.
//  Copyright © 2017 Gurpreet Singh. All rights reserved.
//

import UIKit
import Cosmos

class RatingCell: UITableViewCell {

    @IBOutlet var image_view: UIImageView!
    @IBOutlet var name_lbl: UILabel!
    @IBOutlet var rating_view: CosmosView!
    
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
