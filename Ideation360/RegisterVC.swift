//
//  RegisterVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 14/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit
import CoreData
import AFNetworking

class RegisterVC: AppContentFile {

    @IBOutlet var firstname_tf: UITextField!
    @IBOutlet var lastname_tf: UITextField!
    @IBOutlet var company_tf: UITextField!
    @IBOutlet var email_tf: UITextField!
    @IBOutlet var pass_tf: UITextField!
    
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
    
    @IBAction func signup_btn(_ sender: AnyObject) {
        
        if firstname_tf.text!.isEmpty || lastname_tf.text!.isEmpty || company_tf.text!.isEmpty || email_tf.text!.isEmpty || pass_tf.text!.isEmpty {
            displayAlertMessage(messageAlert: "All fields are required")
        }else if !(email_tf.text!.isEmail()){
            displayAlertMessage(messageAlert: "Invalid email address")
        }else if pass_tf.text!.length < 5{
            displayAlertMessage(messageAlert: "Password should contain atleast 5 character")
        }else if checkbox_count == 0 {
            displayAlertMessage(messageAlert: "Please select the checkbox")
        }else{
            registerCall()
        }
        
    }
    
    func registerCall() {
        showHUD()
        let param = ["Username": email_tf.text!, "Email": email_tf.text!, "Password": pass_tf.text!, "FirstName": firstname_tf.text!, "LastName": lastname_tf.text!, "CompanyName": company_tf.text!]
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json") as? Set<String>
        
        manager.post(BASE_URL+"register", parameters: param, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            print(jsonResult)
            
            print("Register API success")
            let status = jsonResult["Status"] as? String
            if status != nil {
                self.saveDataLocally(entity_name: "LoginTable", _data: result_data!)
            }else{
                let message = jsonResult["Message"] as! String
                self.displayAlertMessage(messageAlert: message)
            }
            
            self.hideHUD()
            
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
    }
    
    
    func saveDataLocally(entity_name: String, _data: Data) {
        
        let enterValue = NSEntityDescription.insertNewObject(forEntityName: entity_name, into: context)
        enterValue.setValue(_data, forKey: "all_data")
        do{ try context.save() } catch _ { }
        
        let AssignmentsCount = getCountOfNumOfAssignments()
        if AssignmentsCount == 1 {
            selectedAssignment = 0
            self.jump_to_storyboard(identifier: "MyIdeasVC")
        }else{
            self.jump_to_storyboard(identifier: "ClientsVC")
        }
        
    }
    
    var count = 0
    @IBAction func show_password_btn(_ sender: AnyObject) {
        count += 1
        
        if count == 1 {
            pass_tf.isSecureTextEntry = false
        }else{
            pass_tf.isSecureTextEntry = true
            count = 0
        }
        
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
        jump_to_storyboard(identifier: "WelcomeVC")
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
