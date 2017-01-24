//
//  ViewController.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 07/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit
import CoreData
import AFNetworking

class LoginVC: AppContentFile {
    
    @IBOutlet var username_tf: UITextField!
    @IBOutlet var pass_tf: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func login_btn(_ sender: AnyObject) {
        
        if username_tf.text!.isEmpty || pass_tf.text!.isEmpty {
            displayAlertMessage(messageAlert: "All fields are required")
        }else{
            loginCall()
        }
        
    }
    
    func loginCall() {
        showHUD()
        let param = ["Username": username_tf.text!, "Email": username_tf.text!, "Password": pass_tf.text!]
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json") as? Set<String>
        
        manager.post(BASE_URL+"account", parameters: param, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            print(jsonResult)
            
            print("Login API success")
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
    
    @IBAction func forgot_btn(_ sender: AnyObject) {
        jump_to_storyboard(identifier: "ForgotVC")
    }
    
    @IBAction func ideation360_btn(_ sender: AnyObject) {
        goToWebPortal()
    }
    
    @IBAction func back_btn(_ sender: AnyObject) {
        jump_to_storyboard(identifier: "WelcomeVC")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

