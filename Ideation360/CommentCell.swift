//
//  SavedIdeasCell.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 20/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet var name_lbl: UILabel!
    @IBOutlet var comment_lbl: UILabel!
    @IBOutlet var image_view: UIImageView!
    @IBOutlet var view_more_btn: UIButton!
    
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
