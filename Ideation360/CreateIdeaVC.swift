//
//  CreateIdeaVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 13/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit
import AFNetworking
import Toast_Swift
import CoreData
import IQAudioRecorderController

class CreateIdeaVC: AppContentFile, ZHDropDownMenuDelegate, IQAudioRecorderViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet var campaignMenu: ZHDropDownMenu!
    @IBOutlet var site_of_idea_tf: UITextField!
    @IBOutlet var description_text_box: UITextView!
    
    @IBOutlet var scroll_view: UIScrollView!
    @IBOutlet var post_btn_outlet: UIButton!
    @IBOutlet var save_btn_outlet: UIButton!
    
    @IBOutlet var photo_btn_outlet: UIButton!
    @IBOutlet var sound_btn_outlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isInternetAvailable() == false {
            post_btn_outlet.isEnabled = false
        }else{
            post_btn_outlet.isEnabled = true
        }
        
        scroll_view.contentSize = CGSize(width: 0, height: save_btn_outlet.frame.origin.y + save_btn_outlet.frame.size.height + 30)
        
    }
    
    var savedDictData = Dictionary<String, String>()
    override func viewWillAppear(_ animated: Bool) {
        if isLoadAgain != true {
            
            if savedDictData.isEmpty {
                let _ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
                Get_all_campaigns_for_ideator(ideator_id: _ideator_id)
            }else{
                
                campaignMenu.contentTextField.text = savedDictData["campaign_title"]
                site_of_idea_tf.text = savedDictData["idea_title"]
                description_text_box.text = savedDictData["description"]
                campaign_Id = savedDictData["campaign_id"]!
                
            }
            
        }
    }
    
    var searchText = String()
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        searchText = (searchText as NSString).replacingCharacters(in: range, with: string)
        
        if searchText.length > 150 {
            searchText = textField.text!
            return false
        }else{
            
//            let remainingChar = searchText.length
//            idea_tf_count.text = "\(remainingChar)/150"
            
            return true
        }
        
    }
   
    var searchText1 = String()
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        searchText1 = (searchText1 as NSString).replacingCharacters(in: range, with: text)
        
        if searchText1.length > 2500 {
            searchText = textView.text!
            return false
        }else{
            
//            let remainingChar = searchText1.length
//            description_tf_count.text = "\(remainingChar)/2500"
            
            return true
        }
        
    }
    
    var campaign_Id = String()
    func dropDownMenu(_ menu: ZHDropDownMenu!, didChoose index: Int) {
        print("\(menu) choosed at index \(index)")
        campaign_Id = self.menuArr[index]["id"]!
    }
    
    func dropDownMenu(_ menu: ZHDropDownMenu!, didInput text: String!) {
        print("\(menu) input text \(text)")
    }
    
    @IBAction func camera_btn(_ sender: AnyObject) {
        customActionSheet()
    }

    @IBAction func recording_btn(_ sender: AnyObject) {
        
        let controller = IQAudioRecorderViewController()
        controller.delegate = self
        controller.title = "Recorder"
        controller.maximumRecordDuration = 60
        controller.allowCropping = false
        self.presentBlurredAudioRecorderViewControllerAnimated(controller)
        
    }
    
    func containData(array: [[String: String]], _value: String) -> Bool {
        for item in array {
            if item["type"] == _value {
                return true
            }
        }
        return false
    }
    
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        
        sound_btn_outlet.backgroundColor = UIColor.lightGray
        
        if  containData(array: uploadMediaData, _value: "2") {
            let index = uploadMediaData.index{ $0["type"] == "2"}
            uploadMediaData.remove(at: index!)
            uploadMediaData.append(["data": filePath, "type": "2"])
        }else{
            uploadMediaData.append(["data": filePath, "type": "2"])
        }
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
// MARK: UIImagePickerControllerDelegate
    var isLoadAgain = Bool()
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isLoadAgain = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let mediaData = UIImageJPEGRepresentation(selectedImage, 0.1)!
        photo_btn_outlet.backgroundColor = UIColor.lightGray
        let strBase64:String = mediaData.base64EncodedString(options: .lineLength64Characters)
        
        if  containData(array: uploadMediaData, _value: "1") {
            let index = uploadMediaData.index{ $0["type"] == "1"}
            uploadMediaData.remove(at: index!)
            uploadMediaData.append(["data": strBase64, "type": "1"])
        }else{
            uploadMediaData.append(["data": strBase64, "type": "1"])
        }
        
        isLoadAgain = true
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func save_btn(_ sender: AnyObject) {
        
        if site_of_idea_tf.text!.isEmpty {
            displayAlertMessage(messageAlert: "Idea title field is required")
        }else{
            
            if !(self.savedDictData.isEmpty) {
                self._clear_Local_Data()
            }
            
            let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
            
            let enterValue = NSEntityDescription.insertNewObject(forEntityName: "SavedIdeas", into: context)
            enterValue.setValue(ideator_id, forKey: "ideator_id")
            enterValue.setValue(campaign_Id, forKey: "ideation_activity_id")
            enterValue.setValue(site_of_idea_tf.text!, forKey: "ideaTitle")
            enterValue.setValue(campaignMenu.contentTextField.text!, forKey: "campaignTitle")
            enterValue.setValue(description_text_box.text!, forKey: "ideaDescription")
            enterValue.setValue("", forKey: "profile")
            let globalTime = time_t(Date().timeIntervalSince1970)
            enterValue.setValue(String(globalTime), forKey: "time")
            
            do{ try context.save() } catch _ { }
            
            data_reset()
            self.displayAlertWithAction(messageAlert: "Idea saved successfully", goToIdentifier: "SavedIdeaVC")
            
        }
        
    }
    
    @IBAction func post_btn(_ sender: AnyObject) {
        
        if campaignMenu.contentTextField.text!.isEmpty || site_of_idea_tf.text!.isEmpty || description_text_box.text!.isEmpty {
            displayAlertMessage(messageAlert: "All fields are required")
        }else{
            
            if savedDictData.isEmpty {
                let _ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
                Post_an_idea(ideator_id: _ideator_id)
            }else{
                let _ideator_id = savedDictData["ideator_id"]!
                Post_an_idea(ideator_id: _ideator_id)
            }
            
        }
        
    }
    
    var ideaID = String()
    func Post_an_idea(ideator_id: String) {
        showProgressHUD()
        
        let param = ["CampaignId": campaign_Id, "IdeatorId": ideator_id, "Title": site_of_idea_tf.text!, "Description": description_text_box.text!]
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        manager.post(BASE_URL+"addidea", parameters: param, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            print(jsonResult)
            
            let status = jsonResult["Status"] as? String
            if status != nil {
                
                if !(self.savedDictData.isEmpty) {
                    self._clear_Local_Data()
                }
                
                if self.uploadMediaData.count > 0{
                    self.ideaID = String(describing: jsonResult["IdeaId"] as! Int)
                    
                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(CreateIdeaVC.uploadCall), userInfo: nil, repeats: false)
                }else{
                    self.hideProgressHUD()
                    self.data_reset()
                    self.back_previous_storyboard()
                }
                
            }else{
                self.hideProgressHUD()
                let message = jsonResult["Message"] as! String
                self.displayAlertMessage(messageAlert: message)
            }
            
            }, failure: { (task, error) -> Void in
                self.hideProgressHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
    }
    
    func uploadCall() {
        self.uploadMedia(idea_id: ideaID)
    }
    
    var uploadMediaData: [Dictionary<String, String>] = []
    func uploadMedia(idea_id: String) {
        
        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let mediaType = uploadMediaData[0]["type"]!
        let api_url = BASE_URL+"uploadmedia/\(idea_id)/\(ideator_id)/\(mediaType)"
        manager.post(api_url, parameters: nil, constructingBodyWith: { (data) -> Void in
            
            let mediaType = self.uploadMediaData[0]["type"]!
            if mediaType == "1" {
                
                let mediaData = self.uploadMediaData[0]["data"]!
                let imageData:Data = NSData(base64Encoded: mediaData, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)! as Data
                data.appendPart(withFileData: imageData, name: "", fileName: "image.png", mimeType: "image/png")
            }else{
                
                let mediaData = self.uploadMediaData[0]["data"]!
                try! data.appendPart(withFileURL: NSURL(fileURLWithPath: mediaData) as URL, name: "", fileName: "sound.mp3", mimeType: "sound/mp3")
            }
            }, progress: { (progress) -> Void in
                
                self.updateProgrssbar(progress: Float(progress.fractionCompleted), lbl_string: "Uploading")
                
            }, success: { (task, response) -> Void in
                
                let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
                print(responseString!)
                let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
                let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                print(jsonResult)
                
                self.uploadMediaData.remove(at: 0)
                
                if self.uploadMediaData.count == 0 {
                    self.hideProgressHUD()
                    self.back_previous_storyboard()
                }else{
                    self.uploadMedia(idea_id: self.ideaID)
                }
                
            }, failure: { (task, error) -> Void in
                self.hideProgressHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
    }
    
    var menuArr: [Dictionary<String, String>] = []
    func Get_all_campaigns_for_ideator(ideator_id: String) {
        showHUD()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        manager.get(BASE_URL+"mycampaigns/\(ideator_id)", parameters: nil, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSArray
            print(jsonResult)
            
            self.menuArr.removeAll(keepingCapacity: true)
            for i in 0 ..< jsonResult.count {
                let data = jsonResult[i] as! NSDictionary
                let CampaignId = data["CampaignId"] as! Int
                let name = data["Name"] as! String
                
                self.menuArr.append(["name": name, "id": String(CampaignId)])
            }
            
            self.hideHUD()
            if self.menuArr.count > 0 {
                
                for i in 0 ..< self.menuArr.count {
                    self.campaignMenu.options.append(self.menuArr[i]["name"]!)
                }
                
                self.campaignMenu.defaultValue = self.menuArr[0]["name"]!
                self.campaign_Id = self.menuArr[0]["id"]!
                self.campaignMenu.delegate = self
            }
            
            }, failure: { (task, error) -> Void in
                self.hideHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
        
    }
    
    func _clear_Local_Data() {
        let findValue = savedDictData["time"]!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedIdeas")
        request.predicate = NSPredicate(format: "time == %@", findValue)
        request.returnsObjectsAsFaults = false
        let userLoginStatus = try! context.fetch(request) as! [NSManagedObject]
        
        if userLoginStatus.count > 0 {
            for data: AnyObject in userLoginStatus {
                context.delete(data as! NSManagedObject)
            }
            do { try context.save() } catch _ {}
        }
    }
    
    @IBAction func back_btn(_ sender: AnyObject) {
        data_reset()
        back_previous_storyboard()
    }
    
    func data_reset() {
        uploadMediaData.removeAll(keepingCapacity: true)
        savedDictData.removeAll(keepingCapacity: true)
        site_of_idea_tf.text = nil
        description_text_box.text = nil
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

extension Array {
    func _contains<T>(obj: T) -> Bool where T : Equatable, T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}
