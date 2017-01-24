//
//  ForgotVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 27/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit

class ForgotVC: AppContentFile {

    @IBOutlet var email_tf: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func reset_btn(_ sender: AnyObject) {
        displayAlertMessage(messageAlert: "Not implemented yet")
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
