//
//  CommentsVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 17/01/17.
//  Copyright © 2017 Gurpreet Singh. All rights reserved.
//

import UIKit
import AFNetworking

class CommentsVC: AppContentFile, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var comment_tbl: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Get_details_about_an_idea()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommentDic.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    var cellHeight = CGFloat()
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentVCCell
        
        cell.name_lbl.text = CommentDic[indexPath.row]["name"]
        
        cell.desc_lbl.frame.size.height = 0
        cell.desc_lbl.numberOfLines = 0
        cell.desc_lbl.text = CommentDic[indexPath.row]["comment"]
        cell.desc_lbl.sizeToFit()
        
        cellHeight = cell.desc_lbl.frame.origin.y + cell.desc_lbl.frame.size.height + 8
        
        let ideatorID = CommentDic[indexPath.row]["ideatorId"]!
        let imagUrl = getImageUrl + "\(ideatorID)"
        cell.image_view.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "placeholder_image"))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if cellHeight > 86 {
            return cellHeight
        }else{
            return 86
        }
    }
    
    
    var idea_id = String()
    var CommentDic: [Dictionary<String, String>] = []
    func Get_details_about_an_idea() {
        
        showHUD()
        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json") as? Set<String>
        
        let api_url = BASE_URL+"idea/\(idea_id)/\(ideator_id)"
        manager.get(api_url, parameters: nil, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            print(jsonResult)
            
            self.CommentDic.removeAll(keepingCapacity: true)
            let commentsData = jsonResult["Comments"] as! NSArray
            for i in 0 ..< commentsData.count {
                let data = commentsData[i] as! NSDictionary
                
                let name = data["IdeatorName"] as! String
                let comment = data["Comment"] as! String
                let commentId = data["IdeaCommentId"] as! Int
                let ideatorId = data["IdeatorId"] as! Int
                
                self.CommentDic.append(["commentId": String(commentId), "ideatorId": String(ideatorId), "name": name, "comment": comment])
                print(data)
            }
            
            self.hideHUD()
            self.comment_tbl.reloadData()
            
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
