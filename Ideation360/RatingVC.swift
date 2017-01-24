//
//  RatingVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 17/01/17.
//  Copyright © 2017 Gurpreet Singh. All rights reserved.
//

import UIKit
import AFNetworking


class RatingVC: AppContentFile, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var rating_tbl: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6 //campaignDataDic.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//            as! RatingCell
//        
//        cell.name_lbl.text = campaignDataDic[indexPath.row]["title"]
//        
//        let ratingValue = campaignDataDic[indexPath.row]["rating"]!
//        cell.rating_view.rating = Double(ratingValue)!
//        
//        let ideatorID = campaignDataDic[indexPath.row]["IdeatorId"]!
//        let imagUrl = getImageUrl + "\(ideatorID)"
//        cell.image_view.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "placeholder_image"))
        
        
        return cell
    }
    
    var ideatorIdeasDic: [Dictionary<String, String>] = []
    func Get_all_ideas_posted_by_ideator() {
        showHUD()
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
                
                self.ideatorIdeasDic.append(["id": String(id), "IdeatorId":  String(IdeatorId), "title": title, "CampaignTitle": CampaignTitle, "rating": String(rating)])
            }
            
            if self.ideatorIdeasDic.count > 0 {
                self.ideatorIdeasDic.sort{
                    Int(($0)["id"]!)! > Int(($1)["id"]!)!
                }
            }
            
            self.hideHUD()
            self.rating_tbl.reloadData()
            
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
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
