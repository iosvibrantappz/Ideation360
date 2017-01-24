//
//  IdeasCell.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 19/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit
import Cosmos

class IdeasCell: UITableViewCell {
    
    @IBOutlet var image_view: UIImageView!
    @IBOutlet var title_lbl: UILabel!
    @IBOutlet var subtitle_lbl: UILabel!
    @IBOutlet var date_lbl: UILabel!
    @IBOutlet var rating_view: CosmosView!
    @IBOutlet var num_of_comment: UIButton!
    @IBOutlet var num_of_rating: UIButton!
    
    
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
