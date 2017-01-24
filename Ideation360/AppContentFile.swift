//
//  AppContentFile.swift
//  Revalidation
//
//  Created by Sukhwinder Singh on 22/2/16.
//  Copyright © 2015 Gurpreet Singh. All rights reserved.
//

import UIKit
import CoreData
import AFNetworking
import MBProgressHUD
import JDropDownAlert
import SDWebImage

// GLOBAL OBJECTS
var myStoryboard = UIStoryboard(name: "Main", bundle: nil)
var appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
var context : NSManagedObjectContext = appDel.managedObjectContext
var SectionLoginData = NSDictionary()
var BASE_URL = "https://app.ideation360.com/api/"
var deviceTokenString = String()
var appCommonFileObject = AppContentFile()
var navigation = UINavigationController()
var manager = AFHTTPSessionManager()
var alertTitle = "Ideation360"
var IS_IPAD = UIDevice.current.userInterfaceIdiom
var getImageUrl = "https://app.ideation360.com/api/getprofileimage/"
var getMediaForIdea = "https://app.ideation360.com/api/getmedia/"

class AppContentFile: UIViewController, MBProgressHUDDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var _sdWebImageDownloader = SDWebImageDownloader()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
        {
            myStoryboard = UIStoryboard(name: "Main_iPad", bundle: nil)
        }
        else
        {
            myStoryboard = UIStoryboard(name: "Main", bundle: nil)
        }
        
        _sdWebImageDownloader = SDWebImageDownloader.shared()
        _sdWebImageDownloader.setValue("Basic c2FBcHA6dWpyTE9tNGVy", forHTTPHeaderField: "Authorization")
        
    }
    
    
    // FETCH FILE NAME FROM URL
    func filenameFromURL(url: String) -> String {
        let filename = NSURL(string: url)?.lastPathComponent
        return filename!
    }
    
    var fileNamesArr: [String] = []
    func isFileExists(url: String) -> Bool {
        let urlOfFile = url
        let filename = filenameFromURL(url: urlOfFile)
        
        let request1 = NSFetchRequest<NSFetchRequestResult>(entityName: "Download")
        request1.returnsObjectsAsFaults = false
        let results1 = try! context.fetch(request1) as! [NSManagedObject]
        
        fileNamesArr.removeAll(keepingCapacity: true)
        if results1.count > 0 {
            
            for data in results1 {
                let file = data.value(forKey: "file_name") as! String
                self.fileNamesArr.append(file)
            }
            
            if self.fileNamesArr.contains(filename) {
                return true
            }else{
                return false
            }
            
        }else{
            return false
        }
        
    }
    
    func getCountOfNumOfAssignments() -> Int {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LoginTable")
        request.returnsObjectsAsFaults = false
        let results = try! context.fetch(request) as! [NSManagedObject]
        
        if results.count > 0 {
            for data in results {
                let _data = data.value(forKey: "all_data") as! Data
                let jsonResult = (try! JSONSerialization.jsonObject(with: _data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                print(jsonResult)
                
                AssignmentsDic.removeAll(keepingCapacity: true)
                let IdeatorData = jsonResult["Assignments"] as! NSArray
                for i in 0 ..< IdeatorData.count {
                    let data = IdeatorData[i] as! NSDictionary
                    let companyName = data["CompanyName"] as! String
                    let ideatorID = data["IdeatorId"] as! String
                    
                    AssignmentsDic.append(["company": companyName, "ideatorID": ideatorID])
                }
                
                return IdeatorData.count
            }
            
        }
        
        return 0
    }

/* ######################### IDEATION360.COM URL LINK ##########################*/
    func goToWebPortal() {
        UIApplication.shared.openURL(URL(string: "http://www.ideation360.com")!)
    }
    
    func jump_to_storyboard(identifier: String) {
        let vc = myStoryboard.instantiateViewController(withIdentifier: identifier) as UIViewController
        navigation.pushViewController(vc, animated: false)
    }
    
/* ######################### JUMP TO STORYBOARD ##########################*/
    func jump_from_root_storyboard(identifier: String) {
        var naviGation: UINavigationController?
        
        let vc = myStoryboard.instantiateViewController(withIdentifier: identifier)
        naviGation = UINavigationController(rootViewController: vc)
        appDel.window!.rootViewController = naviGation
        navigation.setNavigationBarHidden(true, animated: false)
        
    }
    
    func back_previous_storyboard() {
        navigation.popViewController(animated: false)
    }
    
/* <<<<<<<<<<<<<<<<<<<<<<<  CLEAR LOCAL DATA  >>>>>>>>>>>>>>>>>>>>>>>>>>>> */
    func clearLocalData(entity: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        request.returnsObjectsAsFaults = false
        let userLoginStatus = try! context.fetch(request) as! [NSManagedObject]
        
        if userLoginStatus.count > 0 {
            for data: AnyObject in userLoginStatus {
                context.delete(data as! NSManagedObject)
            }
            do { try context.save() } catch _ {}
        }
    }
    
/* <<<<<<<<<<<<<<<<<<<<<<<<  CUSTOM LOADER  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
    // LOADING HUD
    var Loading = MBProgressHUD()
    func showHUD() {
        
        Loading = MBProgressHUD(view: self.view)
        self.view.addSubview(Loading)
        Loading.delegate = self
        Loading.label.text = "Loading"
        
        Loading.show(animated: true)
    }
    
    func hideHUD() {
        Loading.removeFromSuperview()
        Loading.hide(animated: true)
    }
    
    // LOADING HUD WITH PROGRESS
    var downloading = MBProgressHUD()
    func showProgressHUD() {
        
        downloading = MBProgressHUD(view: self.view)
        self.view.addSubview(downloading)
        downloading.delegate = self
//        downloading.mode = MBProgressHUDMode.determinateHorizontalBar
        downloading.show(animated: true)
    }
    
    func updateProgrssbar(progress: Float, lbl_string: String) {
        
        DispatchQueue.main.async {
            self.downloading.label.text = NSString(format: "\(lbl_string) %.0f%%" as NSString, progress*100) as String
        }

    }
    
    func hideProgressHUD() {
        downloading.removeFromSuperview()
        downloading.hide(animated: true)
    }
    
/* <<<<<<<<<<<<<<<<<<<<<<<  MOVE VIEW  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
    func animateViewMoving (View: UIView, up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        View.frame = View.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
/* <<<<<<<<<<<<<<<<  CUSTOM ALERT CODE BLOCK  >>>>>>>>>>>>>>>>>>>> */
    func displayAlertMessage(messageAlert: String) {
        let alert = UIAlertController(title: alertTitle, message: messageAlert, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func displayAlertWithAction(messageAlert: String, goToIdentifier: String) {
        let alert = UIAlertController(title: alertTitle, message: messageAlert, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: {(action) -> Void in
            self.jump_to_storyboard(identifier: goToIdentifier)
        })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func displayAlertAndGoBackPreviousScreen(messageAlert: String) {
        let alert = UIAlertController(title: alertTitle, message: messageAlert, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: {(action) -> Void in
            self.back_previous_storyboard()
        })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
/* <<<<<<<<<<<<<<<<<  PLACEHOLDER ALERT  >>>>>>>>>>>>>>>>> */
    func textFieldAnimation(placeholder_alert: String, textField: UITextField) {
        
        textField.attributedPlaceholder = NSAttributedString(string: placeholder_alert,
            attributes: [NSForegroundColorAttributeName: UIColor.red])
        
        if textField.text!.isEmpty {
            textField.layer.backgroundColor = UIColor.red.cgColor
            
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 10, y: textField.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: textField.center.x + 10, y: textField.center.y))
            textField.layer.add(animation, forKey: "position")
            
        }
        
    }
    
/* <<<<<<<<<<<<<<<<< For OPEN GALLERY >>>>>>>>>>>>>>>>>>>*/
    
    var picker = UIImagePickerController()
    func openCamera(){
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            self.picker.sourceType = UIImagePickerControllerSourceType.camera
            self.picker.delegate = self
            self.picker.allowsEditing = false
            self .present(self.picker, animated: true, completion: nil)
        }
        else
        {
            self.displayAlertMessage(messageAlert: "Camera is not supported")
        }
    }
    
    func openGallary() {
        self.picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.delegate = self
        picker.allowsEditing = false //2
        present(picker, animated: true, completion: nil)
    }
    
    func customActionSheet() {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let myActionSheet = UIAlertController(title: "Choose Image", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            let galleryAction = UIAlertAction(title: "Gallery", style: .default, handler: {
                (action) -> Void in
                self.openGallary()
            })
            let cmaeraAction = UIAlertAction(title: "Camera", style: .default, handler: {
                (action) -> Void in
                self.openCamera()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (action) -> Void in
            })
            
            myActionSheet.addAction(galleryAction)
            myActionSheet.addAction(cmaeraAction)
            myActionSheet.addAction(cancelAction)
            
            self.present(myActionSheet, animated: true, completion: nil)
        }else{
            let myActionSheet = UIAlertController(title: "Choose Image", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let galleryAction = UIAlertAction(title: "Gallery", style: .default, handler: {
                (action) -> Void in
                self.openGallary()
            })
            let cmaeraAction = UIAlertAction(title: "Camera", style: .default, handler: {
                (action) -> Void in
                self.openCamera()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (action) -> Void in
            })
            
            myActionSheet.addAction(galleryAction)
            myActionSheet.addAction(cmaeraAction)
            myActionSheet.addAction(cancelAction)
            
            self.present(myActionSheet, animated: true, completion: nil)
        }
        
    }
    
/* <<<<<<<<<<<<<<<<< CHECK FOR INTERNET CONNECTION >>>>>>>>>>>>>>>>>>>*/ 
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    
    
}

// Get length of string
extension String {
    var length: Int { return self.characters.count }
}

// Check Email string
extension String {
    func isEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
    
    var isPhoneNumber: Bool {
        let charcter  = NSCharacterSet(charactersIn: "+0123456789").inverted
        var filtered:NSString!
        let inputString: NSArray = self.components(separatedBy: charcter) as NSArray
        filtered = inputString.componentsJoined(by: "") as NSString!
        return  self == filtered as String
    }
    
    
    var isNumber: Bool {
        let charcter  = NSCharacterSet(charactersIn: ".0123456789").inverted
        var filtered:NSString!
        let inputString: NSArray = self.components(separatedBy: charcter) as NSArray
        filtered = inputString.componentsJoined(by: "") as NSString!
        return  self == filtered as String
    }
    
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIColor {
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}

// Getting time interval
extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date)) year ago"   }
        if months(from: date)  > 0 { return "\(months(from: date)) month ago"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date)) week ago"   }
        if days(from: date)    > 0 { return "\(days(from: date)) day ago"    }
        if hours(from: date)   > 0 { return "\(hours(from: date)) hour ago"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date)) min ago" }
        if seconds(from: date) > 0 { return "\(seconds(from: date)) sec ago" }
        return ""
    }
}


