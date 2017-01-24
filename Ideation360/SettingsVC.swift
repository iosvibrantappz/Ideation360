//
//  SettingdVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 27/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit

class SettingsVC: AppContentFile, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    var menuArr = ["Account", "Saved Ideas", "Campaigns", "Invite Friends", "Go to Web Portal", "About", "Help", "Logout"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArr.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch menuArr[indexPath.row] {
        case "Account":
            jump_to_storyboard(identifier: "AccountVC")
        case "Saved Ideas":
            jump_to_storyboard(identifier: "SavedIdeaVC")
        case "Campaigns":
            jump_to_storyboard(identifier: "CampaignsVC")
        case "Invite Friends":
            jump_to_storyboard(identifier: "InviteFriendsVC")
        case "Go to Web Portal":
            let alert = UIAlertController(title: alertTitle, message: "Want to leave the app?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default, handler: {(action) -> Void in
                UIApplication.shared.openURL(URL(string: "http://www.ideation360.com")!)
            })
            let no = UIAlertAction(title: "No", style: .default, handler: nil)
            
            alert.addAction(yes)
            alert.addAction(no)
            present(alert, animated: true, completion: nil)
        case "About":
            jump_to_storyboard(identifier: "AboutVC")
        case "Help":
            displayAlertMessage(messageAlert: "Not Implemented")
        case "Logout":
            let alert = UIAlertController(title: alertTitle, message: "Want to logout?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default, handler: {(action) -> Void in
                self.clearLocalData(entity: "LoginTable")
                self.jump_to_storyboard(identifier: "LoginVC")
            })
            let no = UIAlertAction(title: "No", style: .default, handler: nil)
            
            alert.addAction(yes)
            alert.addAction(no)
            present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuCell
        
        cell.titleText.text = menuArr[indexPath.row]
        
        return cell
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
