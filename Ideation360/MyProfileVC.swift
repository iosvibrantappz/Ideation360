//
//  MyProfileVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 27/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage

class MyProfileVC: AppContentFile, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var user_imageView: BorderImageView!
    @IBOutlet var username_lbl: UILabel!
    @IBOutlet var user_detail_lbl: UILabel!
    
    @IBOutlet var ideasCount: UILabel!
    @IBOutlet var campaignsCount: UILabel!
    @IBOutlet var notification_count: UILabel!
    
    @IBOutlet var ideas_tbl_view: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notification_count.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Get_user_detail()
    }
    
    func attributedField(lbl: UILabel) {
        
        let str = lbl.text!.components(separatedBy: " ")
        
        var myString = NSString()
        var fontSize = CGFloat()
        var boldSize = CGFloat()
        if IS_IPAD == .pad {
            myString = ("\(str[0]) " + str[1]) as NSString
            fontSize = 18.0
            boldSize = 20
        }else{
            myString = ("\(str[0]) " + str[1]) as NSString
            fontSize = 13.0
            boldSize = 20
        }
        
        var attributedString = NSMutableAttributedString(string: myString as String)
        
        let firstAttributes = [NSForegroundColorAttributeName: UIColor(hex: 0x000000)]
        
        attributedString.addAttributes(firstAttributes, range: myString.range(of: str[0]))
        
        attributedString = NSMutableAttributedString(
            string: myString as String,
            attributes: [NSFontAttributeName:UIFont(
                name: "Arial",
                size: fontSize)!])
        
        attributedString.addAttribute(NSFontAttributeName,
                                      value: UIFont.boldSystemFont(ofSize: boldSize),
                                      range: myString.range(of: str[0]))
        
        lbl.attributedText = attributedString
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideatorIdeasDic.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = myStoryboard.instantiateViewController(withIdentifier: "IdeaDetailsVC") as! IdeaDetailsVC
        vc.idea_id = self.ideatorIdeasDic[indexPath.row]["id"]!
        navigation.pushViewController(vc, animated: false)
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
    
    func Get_user_detail() {
        
        showHUD()
        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
        let param = ["": ""]
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json") as? Set<String>
        
        let api_url = BASE_URL+"getprofile/\(ideator_id)"
        manager.get(api_url, parameters: param, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            print(jsonResult)
            
            self.username_lbl.text = jsonResult["FirstName"] as? String
            self.user_detail_lbl.text = jsonResult["Email"] as? String
            
            let ideatorID = jsonResult["IdeatorId"] as! Int
            let imagUrl = getImageUrl + "\(ideatorID)"
            self.user_imageView.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "placeholder_image"), options: SDWebImageOptions.refreshCached)
            
            self.Get_all_ideas_posted_by_ideator()
            
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
    }
    
    
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
            
            self.ideasCount.text = "\(jsonResult.count) ideas"
            self.attributedField(lbl: self.ideasCount)
            self.Get_all_campaigns_for_ideator()
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
    }
    
    func Get_all_campaigns_for_ideator() {
        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
        let param = ["": ""]
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        manager.get(BASE_URL+"mycampaigns/\(ideator_id)", parameters: param, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSArray
            print(jsonResult)
            
            self.campaignsCount.text = "\(jsonResult.count) campaigns"
            self.attributedField(lbl: self.campaignsCount)
            self.hideHUD()
            self.ideas_tbl_view.reloadData()
            
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
    }
    
//    func Get_all_notification_count() {
//        
//        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
//        
//        manager.requestSerializer = AFHTTPRequestSerializer()
//        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
//        manager.responseSerializer = AFHTTPResponseSerializer()
//        
//        manager.get(BASE_URL+"getnrofupdates/\(ideator_id)", parameters: nil, progress: nil, success: { (task, response) -> Void in
//            
//            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
//            print(responseString!)
//            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
//            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSArray
//            print(jsonResult)
//            
//            }, failure: { (task, error) -> Void in
//                self.Get_all_notification_count()
//        })
//        
//    }
    
    @IBAction func notification_btn(_ sender: AnyObject) {
//        jump_to_storyboard(identifier: "NotificationsVC")
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
