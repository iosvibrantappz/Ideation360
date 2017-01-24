//
//  IdeaDetailsVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 14/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit
import AFNetworking
import Cosmos
import StretchHeader
import IQKeyboardManagerSwift
import MMCollapsibleLabel
import SDWebImage

class IdeaDetailsVC: AppContentFile, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var user_imageView: BorderImageView!
    @IBOutlet var same_user_imageView: BorderImageView!
    @IBOutlet var username_lbl: UILabel!
    @IBOutlet var user_detail_lbl: UILabel!
    
    @IBOutlet var titleOfIdea_lbl: UILabel!
    @IBOutlet var titleOfCampaign_lbl: UILabel!
    @IBOutlet var desc_lbl: UILabel!
    
    @IBOutlet var banner_imageView: UIImageView!
    
    @IBOutlet var num_of_comment: UIButton!
//    @IBOutlet var num_of_rating: UIButton!
    
    @IBOutlet var comment_tbl: UITableView!
    @IBOutlet var tbl_header_view: StretchHeader!
    
    @IBOutlet var comment_box: UITextView!
    @IBOutlet var bottom_bar_view: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view_more_btn.isHidden = true
        comment_tbl.tableHeaderView = tbl_header_view
        comment_tbl.tableFooterView = bottom_bar_view
        comment_tbl.bounces = false
        
//        self.comment_tbl.contentInset = UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0)
//        self.comment_tbl.scrollIndicatorInsets = UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0)
//        alert_view.isHidden = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(IdeaDetailsVC.imagePopupCall))
        banner_imageView.isUserInteractionEnabled = true
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        banner_imageView.addGestureRecognizer(gesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Get_user_detail()
        NotificationCenter.default.addObserver(self, selector: #selector(IdeaDetailsVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IdeaDetailsVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//        IQKeyboardManager.sharedManager().enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
//        IQKeyboardManager.sharedManager().enable = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommentDic.count
    }
    
    var cellHeight = CGFloat()
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CommentCell
        
        cell.name_lbl.text = CommentDic[indexPath.row]["name"]
        
        cell.comment_lbl.frame.size.height = 0
        cell.comment_lbl.numberOfLines = 0
        cell.comment_lbl.text = CommentDic[indexPath.row]["comment"]
        cell.comment_lbl.sizeToFit()
        
        cellHeight = cell.comment_lbl.frame.origin.y + cell.comment_lbl.frame.size.height + 25
        
        let ideatorID = CommentDic[indexPath.row]["ideatorId"]!
        let imagUrl = getImageUrl + "\(ideatorID)"
        cell.image_view.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "placeholder_image"))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if cellHeight > 84 {
            return cellHeight
        }else{
            return 84
        }
    }
    
    @IBAction func num_of_comment_btn(_ sender: AnyObject) {
        let vc = myStoryboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        vc.idea_id = idea_id
        navigation.pushViewController(vc, animated: false)
    }
    
//    @IBAction func num_of_rating_btn(_ sender: AnyObject) {
//        jump_to_storyboard(identifier: "RatingVC")
//    }
    
//    @IBAction func send_btn(_ sender: AnyObject) {
//        view.endEditing(true)
//        if (comment_box.text != "") && MyString.blank(text: comment_box.text!) == false {
//            send_message_api()
//            self.comment_box.text = nil
//        }
//    }
    
    func send_message_api() {
        showHUD()
        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
        let param = ["IdeaId": idea_id, "IdeatorId": ideator_id, "Comment": comment_box.text!]
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        manager.post(BASE_URL+"addcomment", parameters: param, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            print(jsonResult)
            
            let status = jsonResult["Status"] as? String
            if status != nil {
                self.Get_details_about_an_idea(_showHud: false)
            }else{
                let message = jsonResult["Message"] as! String
                self.displayAlertMessage(messageAlert: message)
            }
            
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
    }
    
    var idea_id = String()
    var MediaDic: [Dictionary<String, String>] = []
    var CommentDic: [Dictionary<String, String>] = []
    func Get_details_about_an_idea(_showHud: Bool) {
        
        if _showHud == true {
            showHUD()
        }
        
        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
        let param = ["": ""]
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json") as? Set<String>
        
        let api_url = BASE_URL+"idea/\(idea_id)/\(ideator_id)"
        manager.get(api_url, parameters: param, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            print(jsonResult)
            
            let description = jsonResult["Description"] as? String
            let ideaTitle = jsonResult["Title"] as? String
            let campaignTitle = jsonResult["CampaignTitle"] as? String
            let ratingValue = jsonResult["RatingMeanValue"] as! Int
            let num_of_comment = jsonResult["NrOfComments"] as! Int
//            let num_of_rating = jsonResult["NrOfRatings"] as! Int
            
            self.titleOfIdea_lbl.text = ideaTitle
            self.titleOfCampaign_lbl.text = campaignTitle
            
            self.readMoreText(str: description!)
            
            self.rating_view.rating = Double(ratingValue)
            self.num_of_comment.setTitle(String(num_of_comment), for: .normal)
//            self.num_of_rating.setTitle(String(num_of_rating), for: .normal)

            self.CommentDic.removeAll(keepingCapacity: true)
            self.MediaDic.removeAll(keepingCapacity: true)

            let mediaData = jsonResult["Media"] as! NSArray
            for i in 0 ..< mediaData.count {
                let data = mediaData[i] as! NSDictionary
                
                let id  = data["IdeaMediaId"] as! Int
                let type = data["MediaType"] as! String

                self.MediaDic.append(["id": String(id), "type": type])
            }
            
            if  self.containData(array: self.MediaDic, _value: "Photo") {
                
                let index = self.MediaDic.index{ $0["type"] == "Photo"}
                let mediaId = self.MediaDic[index!]["id"]!
                    
                let mediaUrl = getMediaForIdea + "\(self.idea_id)/\(mediaId)"
                self.banner_imageView.sd_setImage(with: URL(string: mediaUrl), placeholderImage: UIImage(named: "placeholder_image"))
                
            }
                
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
            
            if self.CommentDic.count > 0 {
                self.CommentDic.sort{
                    Int(($0)["commentId"]!)! < Int(($1)["commentId"]!)!
                }
                
            }

            self.hideHUD()
            
            if self.CommentDic.count > 0 {
                Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(IdeaDetailsVC.scrollToLastRow), userInfo: nil, repeats: false)
            }
            
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
    }
    
    func scrollToLastRow() {
        self.comment_tbl.reloadData()
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
            let ideatorID = String(jsonResult["IdeatorId"] as! Int)
            self.user_imageView.sd_setImage(with: URL(string: getImageUrl + "\(ideatorID)"), placeholderImage: UIImage(named: "placeholder_image"))
            self.same_user_imageView.sd_setImage(with: URL(string: getImageUrl + "\(ideatorID)"), placeholderImage: UIImage(named: "placeholder_image"))
            
            
            self.Get_details_about_an_idea(_showHud: false)
            
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
    }
    
/* ############################ Keyboard Setup ############################## */
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        
//        let rate = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
//        
//        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
//        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
//        let keyboardRectangle = keyboardFrame.cgRectValue
//        
//        var keyboardHeight = CGFloat()
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            keyboardHeight = keyboardRectangle.height - 100
//        }else{
//            keyboardHeight = keyboardRectangle.height + bottom_bar_view.frame.height
//        }
//        
//        UIView.animate(withDuration: rate.doubleValue) {
//            self.comment_tbl.contentInset = UIEdgeInsetsMake(5.0, 0.0, keyboardHeight+5.0, 0.0)
//            self.comment_tbl.scrollIndicatorInsets = UIEdgeInsetsMake(5.0, 0.0, keyboardHeight+5.0, 0.0)
//        }
//        
//        if !(CommentDic.isEmpty) {
//            self.comment_tbl.layoutIfNeeded()
//            let indexPath = NSIndexPath(row: CommentDic.count - 1, section: 0)
//            self.comment_tbl.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
//        }
        
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        
        if (comment_box.text != "") && MyString.blank(text: comment_box.text!) == false {
            send_message_api()
            self.comment_box.text = nil
        }
        
//        let rate = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
//        let keyboardHeight = bottom_bar_view.frame.height
//        
//        UIView.animate(withDuration: rate.doubleValue) {
//            self.comment_tbl.contentInset = UIEdgeInsetsMake(5.0, 0.0, keyboardHeight+5.0, 0.0)
//            self.comment_tbl.scrollIndicatorInsets = UIEdgeInsetsMake(5.0, 0.0, keyboardHeight+5.0, 0.0)
//        }
        
//        if !(CommentDic.isEmpty) {
//            self.comment_tbl.layoutIfNeeded()
//            let indexPath = NSIndexPath(row: CommentDic.count - 1, section: 0)
//            self.comment_tbl.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
//        }
        
    }

    @IBAction func back_btn(_ sender: AnyObject) {
        self.back_previous_storyboard()
    }
    
/* #########################  CUSTOM RATING POPUP  ######################### */
    
    @IBOutlet var rating_view: CosmosView!
    @IBOutlet var popup_rating_view: CosmosView!
    
    @IBAction func rate_btn(_ sender: AnyObject) {

        if Int(popup_rating_view.rating) == Int(rating_view.rating) {
            displayAlertMessage(messageAlert: "Please update your rating first")
        }else{
            
            showHUD()
            let rating = Int(popup_rating_view.rating)
            let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
            let param = ["IdeaId": idea_id, "IdeatorId": ideator_id, "Value": String(rating)]
            
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
            manager.responseSerializer = AFHTTPResponseSerializer()
            
            manager.post(BASE_URL+"rateidea", parameters: param, progress: nil, success: { (task, response) -> Void in
                
                let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
                print(responseString!)
                let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
                let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                print(jsonResult)
                
                let status = jsonResult["Status"] as? String
                if status != nil {
                    self.Get_details_about_an_idea(_showHud: false)
                }else{
                    let message = jsonResult["Message"] as! String
                    self.displayAlertMessage(messageAlert: message)
                }
                
                }, failure: { (task, error) -> Void in
                    self.hideHUD()
                    self.displayAlertMessage(messageAlert: error.localizedDescription)
            })
            
        }
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
            tbl_header_view.frame.size.height = moveing_view.frame.origin.y + moveing_view.frame.size.height + 8
            comment_tbl.tableHeaderView = tbl_header_view
            comment_tbl.reloadData()
            
        }else{
            desc_lbl.frame = oldFrame
            view_more_btn.setTitle("view more", for: .normal)
            view_more_btn.frame.origin.y =  oldFrame.origin.y + oldFrame.height + 2
            
            moveing_view.frame.origin.y = oldFrame.origin.y + oldFrame.height + 8
            tbl_header_view.frame.size.height = moveing_view.frame.origin.y + moveing_view.frame.size.height + 8
            comment_tbl.tableHeaderView = tbl_header_view
            comment_tbl.reloadData()
            count = 0
        }
        
    }
    
    
/* ######################### OTHER SETUP  ######################### */
    
    func containData(array: [[String: String]], _value: String) -> Bool {
        for item in array {
            if item["type"] == _value {
                return true
            }
        }
        return false
    }
    
    @IBAction func voice_recording_btn(_ sender: AnyObject) {
        
        if  containData(array: MediaDic, _value: "VoiceMemo") {
            let index = MediaDic.index{ $0["type"] == "VoiceMemo"}
            let mediaId = self.MediaDic[index!]["id"]!
            
            let mediaUrl = getMediaForIdea + "\(self.idea_id)/\(mediaId)"
            
            let containerView = UIView()
            containerView.frame = view.frame
            view.addSubview(containerView)
            
            let vc = myStoryboard.instantiateViewController(withIdentifier: "PlayVC") as! PlayVC
            vc.url = mediaUrl
            vc.container = containerView
            self.addChildViewController(vc)
            containerView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
            
        }else{
            displayAlertMessage(messageAlert: "No voice recording available")
        }
        
    }
    
    func imagePopupCall() {
        
        if  containData(array: MediaDic, _value: "Photo") {
            let index = MediaDic.index{ $0["type"] == "Photo"}
            let mediaId = self.MediaDic[index!]["id"]!
            
            let mediaUrl = getMediaForIdea + "\(self.idea_id)/\(mediaId)"
            
            let containerView = UIView()
            containerView.frame = view.frame
            view.addSubview(containerView)
            
            let vc = myStoryboard.instantiateViewController(withIdentifier: "ImagePopupVC") as! ImagePopupVC
            vc.url = mediaUrl
            vc.container = containerView
            self.addChildViewController(vc)
            containerView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
            
        }else{
            displayAlertMessage(messageAlert: "No image available")
        }
        
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

struct MyString {
    static func blank(text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmed.isEmpty
    }
}
