//
//  ProfileVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 14/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit
import SDWebImage
import AFNetworking

class AccountVC: AppContentFile {

    @IBOutlet var user_imageView: BorderImageView!
    @IBOutlet var firstname_lbl: UILabel!
    @IBOutlet var lastname_lbl: UILabel!
    @IBOutlet var company_lbl: UILabel!
    @IBOutlet var email_lbl: UILabel!
    @IBOutlet var ac_type_lbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBOutlet var select_image_btn: UIButton!
    @IBAction func UpdateProfileImageBtn(_ sender: AnyObject) {
        customActionSheet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isLoadAgain != true {
            Get_user_detail()
        }
        
    }
    
// MARK: UIImagePickerControllerDelegate
    var isImageSelected = Bool()
    var isLoadAgain = Bool()
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isLoadAgain = true
        dismiss(animated: true, completion: nil)
    }
    
    var imageData = Data()
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageData = UIImageJPEGRepresentation(selectedImage, 0.1)!
        user_imageView.image = selectedImage
        isLoadAgain = true
        isImageSelected = true
        select_image_btn.setImage(UIImage(named: "edirt icn"), for: .normal)
        select_image_btn.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func update_btn(_ sender: AnyObject) {
        if self.isImageSelected == true {
            self.uploadMedia()
        }else{
            displayAlertMessage(messageAlert: "Please select an image first")
        }
    }
    
    func uploadMedia() {
        showProgressHUD()
        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let api_url = BASE_URL+"updateprofileimage/\(ideator_id)"
        manager.post(api_url, parameters: nil, constructingBodyWith: { (data) -> Void in
            
                data.appendPart(withFileData: self.imageData, name: "", fileName: "profile.png", mimeType: "image/png")
            
            }, progress: { (progress) -> Void in
                
                self.updateProgrssbar(progress: Float(progress.fractionCompleted), lbl_string: "Uploading")
                
            }, success: { (task, response) -> Void in
                
                self.displayAlertMessage(messageAlert: "Image uploaded successfully")
                self.hideProgressHUD()
                
            }, failure: { (task, error) -> Void in
                self.hideProgressHUD()
                self.displayAlertMessage(messageAlert: error.localizedDescription)
        })
    }
    
    @IBAction func ideation360_btn(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "http://www.ideation360.com/#pricingtable")!)
    }
    
    
    func Get_user_detail() {
        
        showHUD()
        let ideator_id = AssignmentsDic[selectedAssignment]["ideatorID"]!
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json") as? Set<String>
        
        let api_url = BASE_URL+"getprofile/\(ideator_id)"
        manager.get(api_url, parameters: nil, progress: nil, success: { (task, response) -> Void in
            
            let responseString = NSString(data: response as! Data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            let result_data = responseString!.data(using: String.Encoding.utf8.rawValue)
            let jsonResult = (try! JSONSerialization.jsonObject(with: result_data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            print(jsonResult)
            
            self.firstname_lbl.text = jsonResult["FirstName"] as? String
            self.lastname_lbl.text = jsonResult["LastName"] as? String
            self.company_lbl.text = jsonResult["CompanyName"] as? String
            let txt = jsonResult["Email"] as! String
            
            let titleString = NSMutableAttributedString(string: txt)
            titleString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, txt.characters.count))
            titleString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSMakeRange(0, txt.characters.count))
            self.email_lbl.attributedText = titleString
            
            self.ac_type_lbl.text = "Silver Account"
            let imageUrl = jsonResult["URL"] as? String
            let ideatorID = jsonResult["IdeatorId"] as! Int
            
            if imageUrl == "" {
                self.select_image_btn.setImage(UIImage(named: "Add icn"), for: .normal)
                self.select_image_btn.backgroundColor = UIColor.clear
            }else{
                
                self.select_image_btn.setImage(UIImage(named: "edirt icn"), for: .normal)
                self.select_image_btn.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                
                let imagUrl = getImageUrl + "\(ideatorID)"
                self.user_imageView.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "placeholder_image"), options: SDWebImageOptions.refreshCached)
            }
            
            self.hideHUD()
            
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
