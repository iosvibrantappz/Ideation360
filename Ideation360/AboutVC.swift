//
//  AboutVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 14/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit

class AboutVC: AppContentFile {

    @IBOutlet var about_description: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func ideation360_btn(_ sender: AnyObject) {
        goToWebPortal()
    }
    
    @IBAction func back_btn(_ sender: AnyObject) {
        back_previous_storyboard()
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
