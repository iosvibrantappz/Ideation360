//
//  MyIdeasVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 14/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage

var isAddIdea = Bool()
class MyIdeasVC: AppContentFile, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var myIdeas_tbl: UITableView!
    @IBOutlet var emptyList_View: UIView!
    @IBOutlet var notification_count: UILabel!

    
    var refreshControl: UIRefreshControl!
    
    func refresh(_ sender: AnyObject) {
        // Code to refresh table view
        Get_all_ideas_posted_by_ideator(isPoolDownEnabled: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myIdeas_tbl.bounces = true
        notification_count.isHidden = true
        navigationController?.isNavigationBarHidden = true
        emptyList_View.isHidden = true
        
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        refreshControl.addTarget(self, action: #selector(MyIdeasVC.refresh(_ :)), for: UIControlEvents.valueChanged)
        myIdeas_tbl.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Get_all_ideas_posted_by_ideator(isPoolDownEnabled: false)
    }
    
    @IBAction func home_btn(_ sender: AnyObject) {
        jump_to_storyboard(identifier: "MyIdeasVC")
    }
    
    @IBAction func setting_btn(_ sender: AnyObject) {
        jump_to_storyboard(identifier: "SettingsVC")
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
        
        cell.date_lbl.text = ideatorIdeasDic[indexPath.row]["date"]
        
        let ideatorID = ideatorIdeasDic[indexPath.row]["IdeatorId"]!
        let imagUrl = getImageUrl + "\(ideatorID)"
        
        cell.image_view.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "placeholder_image"), options: SDWebImageOptions.refreshCached)
        
        
        if indexPath.row == ideatorIdeasDic.count - 1 {
            cell.seprator_lbl.isHidden = true
        }else{
            cell.seprator_lbl.isHidden = false
        }
        
        return cell
        
    }
    
    var ideatorIdeasDic: [Dictionary<String, String>] = []
    func Get_all_ideas_posted_by_ideator(isPoolDownEnabled: Bool) {
        
        if isPoolDownEnabled == false{
            showHUD()
        }
        
        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        manager.get(BASE_URL+"ideatorideas/\(ideator_id)", parameters: nil, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSArray
            print(jsonResult)
            
            self.ideatorIdeasDic.removeAll(keepingCapacity: true)
            for i in 0 ..< jsonResult.count {
                let data = jsonResult[i] as! NSDictionary
                
                let id = data["IdeaId"] as! Int
                let IdeatorId  = data["IdeatorId"] as! Int
                let CampaignTitle = data["CampaignTitle"] as! String
                let title = data["Title"] as! String
                let rating = data["RatingMeanValue"] as! Int
                let num_of_comment = data["NrOfComments"] as! Int
                let num_of_rating = data["NrOfRatings"] as! Int
                let dateString = data["PostedDate"] as! String
                let fetchDate = dateString.components(separatedBy: "T")
                let date = self.dateFromString(dateString: fetchDate[0])
                
                self.ideatorIdeasDic.append(["id": String(id), "IdeatorId":  String(IdeatorId), "title": title, "CampaignTitle": CampaignTitle, "rating": String(rating), "num_of_comment": String(num_of_comment), "num_of_rating": String(num_of_rating), "date": date])
            }
            
            if self.ideatorIdeasDic.count > 0 {
                self.emptyList_View.isHidden = true
                self.myIdeas_tbl.isHidden = false
                
                self.ideatorIdeasDic.sort{
                    Int(($0)["id"]!)! > Int(($1)["id"]!)!
                }
                
            }else{
                self.emptyList_View.isHidden = false
                self.myIdeas_tbl.isHidden = true
            }
            
            if isPoolDownEnabled == true {
                self.refreshControl.endRefreshing()
            }else{
                self.hideHUD()
            }
            
            self.myIdeas_tbl.reloadData()
            
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
    }
    
    func dateFromString(dateString: String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dateString)
        
        formatter.dateFormat = "yyyy'. 'MM'. 'dd"
        let dateStr = formatter.string(from: date!)
        
        return dateStr
        
    }
    
/* ------------- FOOTER VIEW SETUP ------------ */
    
    @IBAction func search_btn(_ sender: AnyObject) {
        jump_to_storyboard(identifier: "SearchVC")
    }
    
    @IBAction func add_btn(_ sender: AnyObject) {
        jump_to_storyboard(identifier: "CreateIdeaVC")
    }
    
    @IBAction func profile_btn(_ sender: AnyObject) {
        jump_to_storyboard(identifier: "MyProfileVC")
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
