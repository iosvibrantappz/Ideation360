//
//  CampaignsVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 14/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit
import AFNetworking

class CampaignsVC: AppContentFile, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var campaigns_tbl: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Get_all_campaigns_for_ideator()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MyIdeationsDic.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = myStoryboard.instantiateViewController(withIdentifier: "CampaignTitleVC") as! CampaignTitleVC
        
        let id = MyIdeationsDic[indexPath.row]["id"]!
        let campaign_name = MyIdeationsDic[indexPath.row]["name"]
        let num_of_ideas = MyIdeationsDic[indexPath.row]["num_of_idea"]!
        let days_left = MyIdeationsDic[indexPath.row]["num_of_day_left"]!
        
        let campaignDetail = ["id": id, "campaign_name": campaign_name, "num_of_ideas": num_of_ideas, "days_left": days_left]
        
        vc.campaignDataDic = campaignDetail as! Dictionary<String, String>
        navigation.pushViewController(vc, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CampaignsCell
        
        cell.name_lbl.text = MyIdeationsDic[indexPath.row]["name"]
        let number_of_ideas = MyIdeationsDic[indexPath.row]["num_of_idea"]!
        cell.numIdeas.text = "\(number_of_ideas) idea submitted"
        
        let number_of_days_left = MyIdeationsDic[indexPath.row]["num_of_day_left"]!
        cell.duration.text = "\(number_of_days_left) day left"
        
        if indexPath.row == MyIdeationsDic.count - 1 {
            cell.seprator_lbl.isHidden = true
        }else{
            cell.seprator_lbl.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    var MyIdeationsDic: [Dictionary<String, String>] = []
    func Get_all_campaigns_for_ideator() {
        showHUD()
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
            
            self.MyIdeationsDic.removeAll(keepingCapacity: true)
            for i in 0 ..< jsonResult.count {
                let data = jsonResult[i] as! NSDictionary
                let description = data["Description"] as! String
                let CampaignId = data["CampaignId"] as! Int
                let name = data["Name"] as! String
                let num_of_idea = data["NrOfIdeas"] as! Int
                let num_of_day_left = data["NrOfDaysLeft"] as! Int
                
                self.MyIdeationsDic.append(["id": String(CampaignId), "name": name, "desc": description, "num_of_idea": String(num_of_idea), "num_of_day_left": String(num_of_day_left)])
            }
            
            if self.MyIdeationsDic.count > 0 {
                self.MyIdeationsDic.sort{
                    Int(($0)["id"]!)! > Int(($1)["id"]!)!
                }
            }
            
            self.hideHUD()
            self.campaigns_tbl.reloadData()
            
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



 /*  


*/
