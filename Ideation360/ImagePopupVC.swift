//
//  ImagePopupVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 17/01/17.
//  Copyright © 2017 Gurpreet Singh. All rights reserved.
//

import UIKit

class ImagePopupVC: AppContentFile {
    
    @IBOutlet var image_view: UIImageView!
    
    var Data = Dictionary<String, String>()
    var url = String()
    var container = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()

        image_view.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder_image"))
        
    }
    
    @IBAction func cancel_btn(_ sender: AnyObject) {
        container.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
