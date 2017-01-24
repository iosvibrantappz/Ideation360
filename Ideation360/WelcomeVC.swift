//
//  WelcomeVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 18/01/17.
//  Copyright © 2017 Gurpreet Singh. All rights reserved.
//

import UIKit

class WelcomeVC: AppContentFile {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
    }
    
    
    @IBAction func login_btn(_ sender: AnyObject) {
        jump_to_storyboard(identifier: "LoginVC")
    }
    
    @IBAction func forgot_btn(_ sender: AnyObject) {
        jump_to_storyboard(identifier: "ForgotVC")
    }
    
    @IBAction func go_to_sign_up_btn(_ sender: AnyObject) {
        jump_to_storyboard(identifier: "RegisterVC")
    }
    
    @IBAction func ideation360_btn(_ sender: AnyObject) {
        goToWebPortal()
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
