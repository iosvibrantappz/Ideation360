//
//  IdeatorCell.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 04/01/17.
//  Copyright © 2017 Gurpreet Singh. All rights reserved.
//

import UIKit

class IdeatorCell: UITableViewCell {
    
    @IBOutlet var firstName_lbl: UILabel!
    @IBOutlet var image_view: UIImageView!
    
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
