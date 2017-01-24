//
//  SavedIdeaVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 14/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit
import CoreData
import AFNetworking
import SDWebImage

class SavedIdeaVC: AppContentFile, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var savedIdeas_tbl: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var storeDataDic: [Dictionary<String, String>] = []
    override func viewWillAppear(_ animated: Bool) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedIdeas")
        request.returnsObjectsAsFaults = false
        let results = try! context.fetch(request) as! [NSManagedObject]
        
        self.storeDataDic.removeAll(keepingCapacity: true)
        if results.count > 0 {
            for data in results {
                let campaign_id = data.value(forKey: "ideation_activity_id") as! String
                let ideator_id = data.value(forKey: "ideator_id") as! String
                let ideaTitle = data.value(forKey: "ideaTitle") as! String
                let campaignTitle = data.value(forKey: "campaignTitle") as! String
                let description = data.value(forKey: "ideaDescription") as! String
                let time = data.value(forKey: "time") as! String
                
                self.storeDataDic.append(["campaign_id": campaign_id, "ideator_id": ideator_id, "ideaTitle": ideaTitle, "description": description, "time": time, "campaignTitle": campaignTitle])
            }
            
        }
        
        savedIdeas_tbl.reloadData()
        
    }
    
    func fetch_current_time(_date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let dateString = formatter.string(from: _date)
        return dateString
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storeDataDic.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = myStoryboard.instantiateViewController(withIdentifier: "CreateIdeaVC") as! CreateIdeaVC
        let campaign_id = storeDataDic[indexPath.row]["campaign_id"]
        let ideator_id = storeDataDic[indexPath.row]["ideator_id"]
        let idea_title = storeDataDic[indexPath.row]["ideaTitle"]
        let campaign_title = storeDataDic[indexPath.row]["campaignTitle"]
        let description = storeDataDic[indexPath.row]["description"]
        let time = storeDataDic[indexPath.row]["time"]
        
        let dic = ["campaign_id": campaign_id, "ideator_id": ideator_id, "idea_title": idea_title, "campaign_title": campaign_title, "description": description, "time": time]
        
        vc.savedDictData = dic as! Dictionary<String, String>
        navigation.pushViewController(vc, animated: false)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! IdeasCell
        
        cell.title_lbl.text = storeDataDic[indexPath.row]["ideaTitle"]
        cell.subtitle_lbl.text = storeDataDic[indexPath.row]["campaignTitle"]
        
        cell.rating_view.rating = 0
        cell.num_of_comment.setTitle("0", for: .normal)
        cell.num_of_rating.setTitle("0", for: .normal)
        
        let ideatorID = storeDataDic[indexPath.row]["ideator_id"]!
        let imagUrl = getImageUrl + "\(ideatorID)"
        
        cell.image_view.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "placeholder_image"), options: SDWebImageOptions.refreshCached)
        
        
        if indexPath.row == storeDataDic.count - 1 {
            cell.seprator_lbl.isHidden = true
        }else{
            cell.seprator_lbl.isHidden = false
        }
        
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
