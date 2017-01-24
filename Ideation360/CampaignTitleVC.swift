//
//  CampaignTitleVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 14/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit
import AFNetworking

class CampaignTitleVC: AppContentFile, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var user_imageView: BorderImageView!
    @IBOutlet var sponser_name_lbl: UILabel!
    @IBOutlet var sponser_title_lbl: UILabel!
    @IBOutlet var desc_lbl: UILabel!
    
    @IBOutlet var campaign_name_lbl: UILabel!
    @IBOutlet var num_of_ideas_btn: UIButton!
    @IBOutlet var days_left_lbl: UILabel!
    
    @IBOutlet var header_view: UIView!
    @IBOutlet var footer_view: UIView!
    
    @IBOutlet var ideas_tbl_view: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view_more_btn.isHidden = true
        ideas_tbl_view.tableHeaderView = header_view
        ideas_tbl_view.tableFooterView = footer_view
        ideas_tbl_view.bounces = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Get_details_about_a_campaign()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideatorIdeasDic.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = myStoryboard.instantiateViewController(withIdentifier: "IdeaDetailsVC") as! IdeaDetailsVC
//        vc.idea_id = self.ideatorIdeasDic[indexPath.row]["id"]!
//        navigation.pushViewController(vc, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! IdeasCell
        
        cell.title_lbl.text = ideatorIdeasDic[indexPath.row]["title"]
        cell.subtitle_lbl.text = ideatorIdeasDic[indexPath.row]["CampaignTitle"]
        
        let ratingValue = ideatorIdeasDic[indexPath.row]["rating"]!
        let num_of_comment = ideatorIdeasDic[indexPath.row]["num_of_comment"]!
        let num_of_rating = ideatorIdeasDic[indexPath.row]["num_of_rating"]!
        
        cell.rating_view.rating = Double(ratingValue)!
        cell.num_of_comment.setTitle(num_of_comment, for: .normal)
        cell.num_of_rating.setTitle(num_of_rating, for: .normal)
        
        let ideatorID = ideatorIdeasDic[indexPath.row]["IdeatorId"]!
        let imagUrl = getImageUrl + "\(ideatorID)"
        cell.image_view.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "placeholder_image"))
        
        if indexPath.row == ideatorIdeasDic.count - 1 {
            cell.seprator_lbl.isHidden = true
        }else{
            cell.seprator_lbl.isHidden = false
        }
        
        return cell
    }
    
//    func Get_user_detail() {
//        
//        showHUD()
//        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
//        let param = ["": ""]
//        
//        manager.requestSerializer = AFHTTPRequestSerializer()
//        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
//        manager.responseSerializer = AFHTTPResponseSerializer()
//        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json") as? Set<String>
//        
//        let api_url = BASE_URL+"getprofile/\(ideator_id)"
//        manager.get(api_url, parameters: param, progress: nil, success: { (task, response) -> Void in
//            
//            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
//            print(responseString!)
//            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
//            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
//            print(jsonResult)
//            
//            self.username_lbl.text = jsonResult["FirstName"] as? String
//            self.user_detail_lbl.text = jsonResult["Email"] as? String
//            
//            let ideatorID = jsonResult["IdeatorId"] as! Int
//            let imagUrl = getImageUrl + "\(ideatorID)"
//            self.user_imageView.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "placeholder_image"), options: SDWebImageOptions.refreshCached)
//            
//            self.Get_all_ideas_posted_by_ideator()
//            
//            }, failure: { (task, error) -> Void in
//                self.hideHUD()
//                self.displayAlertMessage(messageAlert: error.localizedDescription)
//        })
//        
//    }
    
    
    var ideatorIdeasDic: [Dictionary<String, String>] = []
    func Get_all_ideas_posted_by_ideator() {
        
        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
        let param = ["": ""]
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        manager.get(BASE_URL+"ideatorideas/\(ideator_id)", parameters: param, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSArray
            print(jsonResult)
            
            self.ideatorIdeasDic.removeAll(keepingCapacity: true)
            for i in 0 ..< jsonResult.count {
                let data = jsonResult[i] as! NSDictionary
                
                let id  = data["IdeaId"] as! Int
                let IdeatorId  = data["IdeatorId"] as! Int
                let CampaignTitle = data["CampaignTitle"] as! String
                let title = data["Title"] as! String
                let rating = data["RatingMeanValue"] as! Int
                let num_of_comment = data["NrOfComments"] as! Int
                let num_of_rating = data["NrOfRatings"] as! Int
                
                self.ideatorIdeasDic.append(["id": String(id), "IdeatorId":  String(IdeatorId), "title": title, "CampaignTitle": CampaignTitle, "rating": String(rating), "num_of_comment": String(num_of_comment), "num_of_rating": String(num_of_rating)])
            }
            
            if self.ideatorIdeasDic.count > 0 {
                self.ideatorIdeasDic.sort{
                    Int(($0)["id"]!)! > Int(($1)["id"]!)!
                }
            }
            
            self.ideas_tbl_view.reloadData()
            self.hideHUD()
            
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
    }
    
    var campaignDataDic = Dictionary<String, String>()
    func Get_details_about_a_campaign() {
        showHUD()
        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
        let campaign_id = campaignDataDic["id"]!
        let param = ["": ""]
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json") as? Set<String>
        
        let api_url = BASE_URL+"campaign/\(campaign_id)/\(ideator_id)"
        manager.get(api_url, parameters: param, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            print(jsonResult)
            
            let campaign_name = jsonResult["Name"] as? String
            let NrOfDaysLeft = jsonResult["NrOfDaysLeft"] as? Int
            let NrOfIdeas = jsonResult["NrOfIdeas"] as? Int
            let description = jsonResult["Description"] as? String
            let sponser_id = jsonResult["SponsorIdeatorId"] as! Int
            
            self.user_imageView.sd_setImage(with: URL(string: getImageUrl + "\(sponser_id)"), placeholderImage: UIImage(named: "placeholder_image"))
            
            self.readMoreText(str: description!)
            
            let sponsor_name = jsonResult["SponsorName"] as? String
            let sponsor_title = jsonResult["SponsorTitle"] as? String
            
            if sponsor_name == "<null>" ||  sponsor_name == ""{
                self.sponser_name_lbl.text = "No sponsor assigned"
            }else{
                self.sponser_name_lbl.text = sponsor_name
            }
            
            if sponsor_title == "<null>" ||  sponsor_title == "" {
                self.sponser_title_lbl.text = "No sponsor assigned"
            }else{
                self.sponser_title_lbl.text = sponsor_title
            }
            
            self.campaign_name_lbl.text = campaign_name
            self.num_of_ideas_btn.setTitle(String(NrOfIdeas!), for: .normal)
            self.days_left_lbl.text = "\(NrOfDaysLeft!) day left"
            
            self.Get_all_ideas_posted_by_ideator()
            
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
    }
    
    
/* #########################  VIEW MORE SETUP  ######################### */
    
    var oldFrame = CGRect()
    var newFrame = CGRect()
    @IBOutlet var view_more_btn: UIButton!
    @IBOutlet var moveing_view: UIView!
    func readMoreText(str: String) {
        
        oldFrame = desc_lbl.frame
        
        desc_lbl.frame.size.height = 0
        desc_lbl.numberOfLines = 0
        desc_lbl.text = str
        desc_lbl.sizeToFit()
        
        newFrame = desc_lbl.frame
        
        if newFrame.height > oldFrame.height {
            view_more_btn.isHidden = false
            view_more_btn.addTarget(self, action: #selector(IdeaDetailsVC.viewMoreBtn), for: .touchUpInside)
            desc_lbl.frame = oldFrame
        }else{
            view_more_btn.isHidden = true
            desc_lbl.frame = oldFrame
        }
        
    }
    
    var count = 0
    func viewMoreBtn() {
        count += 1
        
        if count == 1 {
            desc_lbl.frame = newFrame
            view_more_btn.setTitle("hide", for: .normal)
            view_more_btn.frame.origin.y =  newFrame.origin.y + newFrame.height + 2
            moveing_view.frame.origin.y = newFrame.origin.y + newFrame.height + 8
            header_view.frame.size.height = moveing_view.frame.origin.y + moveing_view.frame.size.height + 8
            ideas_tbl_view.tableHeaderView = header_view
            ideas_tbl_view.reloadData()
            
        }else{
            desc_lbl.frame = oldFrame
            view_more_btn.setTitle("view more", for: .normal)
            view_more_btn.frame.origin.y =  oldFrame.origin.y + oldFrame.height + 2
            moveing_view.frame.origin.y = oldFrame.origin.y + oldFrame.height + 8
            header_view.frame.size.height = moveing_view.frame.origin.y + moveing_view.frame.size.height + 8
            ideas_tbl_view.tableHeaderView = header_view
            ideas_tbl_view.reloadData()
            count = 0
        }
        
    }
    
    @IBAction func submit_idea_btn(_ sender: AnyObject) {
        jump_to_storyboard(identifier: "CreateIdeaVC")
    }
    
    @IBAction func view_idea_btn(_ sender: AnyObject) {
        jump_to_storyboard(identifier: "MyIdeasVC")
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
