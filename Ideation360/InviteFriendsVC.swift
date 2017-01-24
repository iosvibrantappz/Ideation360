//
//  InviteFriendsVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 27/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit
import AFNetworking

class InviteFriendsVC: AppContentFile {

    @IBOutlet var email_tf: UITextField!
    
    var selectedCheckbox = String()
    var unselectedCheckbox = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if IS_IPAD == .pad {
            selectedCheckbox = "checkbox_fill_iPad"
            unselectedCheckbox = "checkbox_blank_iPad"
        }else{
            selectedCheckbox = "checkbox_fill"
            unselectedCheckbox = "checkbox_blank"
        }
        
    }
    
    @IBAction func invite_friend_btn(_ sender: AnyObject) {
        
        if email_tf.text!.isEmpty  {
            displayAlertMessage(messageAlert: "Please enter email first")
        }else if !(email_tf.text!.isEmail()){
            displayAlertMessage(messageAlert: "Invalid email address")
        }else if checkbox_count == 0 {
            displayAlertMessage(messageAlert: "Please select the checkbox")
        }else{
            inviteFriendCall()
        }
        
    }
    
    func inviteFriendCall() {
        showHUD()
        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
        let param = ["IdeatorId": ideator_id, "EmailForInvited": email_tf.text!, "InviteToClient": "true"]
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json") as? Set<String>
        
        manager.post(BASE_URL+"invitefriend", parameters: param, progress: nil, success: { (task, response) -> Void in
            
            let headerFields = task.response as? HTTPURLResponse
            print(headerFields)
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)

            self.hideHUD()
            self.displayAlertAndGoBackPreviousScreen(messageAlert: "Invitation sent successfully")
            
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
    }
    
    var checkbox_count = 0
    @IBOutlet var checkbox_btn_outlet: UIButton!
    @IBAction func checkbox_btn(_ sender: AnyObject) {
        checkbox_count += 1
        
        if checkbox_count == 1 {
            checkbox_btn_outlet.setImage(UIImage(named: selectedCheckbox), for: .normal)
        }else{
            checkbox_btn_outlet.setImage(UIImage(named: unselectedCheckbox), for: .normal)
            checkbox_count = 0
        }
    }
    
    @IBAction func ideation360_btn(_ sender: AnyObject) {
        goToWebPortal()
    }
    
    @IBAction func terms_btn(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "http://www.ideation360.com/terms/")!)
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
