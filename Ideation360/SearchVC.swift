//
//  SearchVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 27/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

extension UIButton {
    func underlineButton(text: String) {
        let titleString = NSMutableAttributedString(string: text)
        titleString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, text.characters.count))
        titleString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSMakeRange(0, text.characters.count))
        self.setAttributedTitle(titleString, for: .normal)
    }
}

extension UIButton {
    func removeUnderlineButton(text: String) {
        let titleString = NSMutableAttributedString(string: text)
        titleString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleNone.rawValue, range: NSMakeRange(0, text.characters.count))
        titleString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSMakeRange(0, text.characters.count))
        self.setAttributedTitle(titleString, for: .normal)
    }
}

import UIKit
import AFNetworking

class SearchVC: AppContentFile, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tbl_view: UITableView!
    @IBOutlet var search_view: UITextField!
    
    @IBOutlet var ideas_btn_outlet: UIButton!
    @IBOutlet var campaigns_btn_outlet: UIButton!
    @IBOutlet var people_btn_outlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(IdeaDetailsVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IdeaDetailsVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    var selectedSegment = 0
    @IBAction func ideas_btn(sender: AnyObject) {
        ideas_btn_outlet.underlineButton(text: "IDEAS")
        campaigns_btn_outlet.removeUnderlineButton(text: "CAMPAIGNS")
        people_btn_outlet.removeUnderlineButton(text: "PEOPLE")
        
        selectedSegment = 0
        tbl_view.reloadData()
    }
    
    @IBAction func campaigns_btn(sender: AnyObject) {
        ideas_btn_outlet.removeUnderlineButton(text: "IDEAS")
        campaigns_btn_outlet.underlineButton(text: "CAMPAIGNS")
        people_btn_outlet.removeUnderlineButton(text: "PEOPLE")
        selectedSegment = 1
        tbl_view.reloadData()
    }
    
    @IBAction func people_btn(sender: AnyObject) {
        ideas_btn_outlet.removeUnderlineButton(text: "IDEAS")
        campaigns_btn_outlet.removeUnderlineButton(text: "CAMPAIGNS")
        people_btn_outlet.underlineButton(text: "PEOPLE")
        selectedSegment = 2
        tbl_view.reloadData()
    }
    
    
    @IBAction func searchText_btn(sender: AnyObject) {
        view.endEditing(true)
        if search_view.text!.isEmpty {
            displayAlertMessage(messageAlert: "Please enter search text")
        }else{
            searchtextApiCall()
        }
    }
    
    var IdeasDic: [Dictionary<String, String>] = []
    var CampaignsDic: [Dictionary<String, String>] = []
    var IdeatorsDic: [Dictionary<String, String>] = []
    func searchtextApiCall() {
        showHUD()
        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
        let param = ["IdeatorId": ideator_id, "SearchFor": search_view.text!]
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        manager.post(BASE_URL+"search", parameters: param, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            print(jsonResult)
            
            let ideas = jsonResult["Ideas"] as! NSArray
            let campaigns = jsonResult["Campaigns"] as! NSArray
            let ideator = jsonResult["Ideators"] as! NSArray
            
            self.IdeasDic.removeAll(keepingCapacity: true)
            for i in 0 ..< ideas.count {
                let data = ideas[i] as! NSDictionary
                
                let id  = data["IdeaId"] as! Int
                let IdeatorId  = data["IdeatorId"] as! Int
                let CampaignTitle = data["CampaignTitle"] as? String
                
                var campTitle = String()
                if CampaignTitle == "<null>" || CampaignTitle == nil {
                    campTitle = ""
                }else{
                    campTitle = CampaignTitle!
                }
                
                let title = data["Title"] as! String
                let rating = data["RatingMeanValue"] as! Int
                let num_of_comment = data["NrOfComments"] as! Int
                let num_of_rating = data["NrOfRatings"] as! Int
                
                self.IdeasDic.append(["id": String(id), "IdeatorId":  String(IdeatorId), "title": title, "CampaignTitle": campTitle, "rating": String(rating), "num_of_comment": String(num_of_comment), "num_of_rating": String(num_of_rating)])
            }
            
            if self.IdeasDic.count > 0 {
                self.IdeasDic.sort{
                    Int(($0)["id"]!)! > Int(($1)["id"]!)!
                }
            }
            
            self.CampaignsDic.removeAll(keepingCapacity: true)
            for i in 0 ..< campaigns.count {
                let data = campaigns[i] as! NSDictionary
                let CampaignId = data["CampaignId"] as! Int
                let name = data["Name"] as! String
                let num_of_idea = data["NrOfIdeas"] as! Int
                let num_of_day_left = data["NrOfDaysLeft"] as! Int
                
                self.CampaignsDic.append(["id": String(CampaignId), "name": name, "num_of_idea": String(num_of_idea), "num_of_day_left": String(num_of_day_left)])
            }
            
            if self.CampaignsDic.count > 0 {
                self.CampaignsDic.sort{
                    Int(($0)["id"]!)! > Int(($1)["id"]!)!
                }
            }
            
            self.IdeatorsDic.removeAll(keepingCapacity: true)
            for i in 0 ..< ideator.count {
                let data = ideator[i] as! NSDictionary
                let ideatorId = data["IdeatorId"] as! Int
                let f_name = data["FirstName"] as! String
                let l_name = data["LastName"] as! String
                
                self.IdeatorsDic.append(["id": String(ideatorId), "f_name": f_name, "l_name": l_name])
            }
            
            if self.IdeatorsDic.count > 0 {
                self.IdeatorsDic.sort{
                    Int(($0)["id"]!)! > Int(($1)["id"]!)!
                }
            }
            
            switch self.selectedSegment {
            case 0:
                if self.IdeasDic.count == 0 {
                    self.displayAlertMessage(messageAlert: "No result found")
                }
            case 1:
                if self.CampaignsDic.count == 0 {
                    self.displayAlertMessage(messageAlert: "No result found")
                }
            case 2:
                if self.IdeatorsDic.count == 0 {
                    self.displayAlertMessage(messageAlert: "No result found")
                }
            default:
                break
            }
            
            self.hideHUD()
            self.tbl_view.reloadData()
            
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedSegment == 1 {
            return CampaignsDic.count
        }else if selectedSegment == 2 {
            return IdeatorsDic.count
        }else{
            return IdeasDic.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedSegment == 1 {
            let vc = myStoryboard.instantiateViewController(withIdentifier: "CampaignTitleVC") as! CampaignTitleVC
            
            let id = CampaignsDic[indexPath.row]["id"]!
            let campaign_name = CampaignsDic[indexPath.row]["name"]
            let num_of_ideas = CampaignsDic[indexPath.row]["num_of_idea"]!
            let days_left = CampaignsDic[indexPath.row]["num_of_day_left"]!
            
            let campaignDetail = ["id": id, "campaign_name": campaign_name, "num_of_ideas": num_of_ideas, "days_left": days_left]
            
            vc.campaignDataDic = campaignDetail as! Dictionary<String, String>
            navigation.pushViewController(vc, animated: false)
        }else if selectedSegment == 2 {
//            jump_to_storyboard(identifier: "MyProfileVC")
//            displayAlertMessage(messageAlert: "Not implemented")
        }else{
            let vc = myStoryboard.instantiateViewController(withIdentifier: "IdeaDetailsVC") as! IdeaDetailsVC
            vc.idea_id = IdeasDic[indexPath.row]["id"]!
            navigation.pushViewController(vc, animated: false)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if selectedSegment == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "campaign_cell", for: indexPath) as! CampaignsCell
            
            cell.name_lbl.text = CampaignsDic[indexPath.row]["name"]
            let number_of_ideas = CampaignsDic[indexPath.row]["num_of_idea"]!
            cell.numIdeas.text = "\(number_of_ideas) idea submitted"
            
            let number_of_days_left = CampaignsDic[indexPath.row]["num_of_day_left"]!
            cell.duration.text = "\(number_of_days_left) day left"
            
            if indexPath.row == CampaignsDic.count - 1 {
                cell.seprator_lbl.isHidden = true
            }else{
                cell.seprator_lbl.isHidden = false
            }
            
            return cell
            
        }else if selectedSegment == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ideator_cell", for: indexPath) as! IdeatorCell
            
            let fName = IdeatorsDic[indexPath.row]["f_name"]!
            let lName = IdeatorsDic[indexPath.row]["l_name"]!
            cell.firstName_lbl.text = "\(fName) \(lName)"
            
            let ideatorID = IdeatorsDic[indexPath.row]["id"]!
            cell.image_view.sd_setImage(with: URL(string: getImageUrl + "\(ideatorID)"), placeholderImage: UIImage(named: "placeholder_image"))
            
            if indexPath.row == IdeatorsDic.count - 1 {
                cell.seprator_lbl.isHidden = true
            }else{
                cell.seprator_lbl.isHidden = false
            }
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "idea_cell", for: indexPath) as! IdeasCell
            
            cell.title_lbl.text = IdeasDic[indexPath.row]["title"]
            cell.subtitle_lbl.text = IdeasDic[indexPath.row]["CampaignTitle"]
            
            let ratingValue = IdeasDic[indexPath.row]["rating"]!
            let num_of_comment = IdeasDic[indexPath.row]["num_of_comment"]!
            let num_of_rating = IdeasDic[indexPath.row]["num_of_rating"]!
            
            cell.rating_view.rating = Double(ratingValue)!
            cell.num_of_comment.setTitle("\(num_of_comment)", for: .normal)
            cell.num_of_rating.setTitle("\(num_of_rating)", for: .normal)
            
            let ideatorID = IdeasDic[indexPath.row]["IdeatorId"]!
            let imagUrl = getImageUrl + "\(ideatorID)"
            cell.image_view.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "placeholder_image"))
            
            if indexPath.row == IdeasDic.count - 1 {
                cell.seprator_lbl.isHidden = true
            }else{
                cell.seprator_lbl.isHidden = false
            }
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedSegment == 1 {
            return 79
        }else if selectedSegment == 2 {
            return 85
        }else{
            return 85
        }
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        if !(search_view.text!.isEmpty) {
            searchtextApiCall()
        }
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
