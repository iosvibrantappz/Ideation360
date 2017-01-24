//
//  PlayVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 17/01/17.
//  Copyright © 2017 Gurpreet Singh. All rights reserved.
//

import UIKit
import MediaPlayer
import AFNetworking
import TCBlobDownload
import CoreData

class PlayVC: AppContentFile {

    var Data = Dictionary<String, String>()
    var url = String()
    var container = UIView()
    
    var sharedDownloadManager = TCBlobDownloadManager()
    override func viewDidLoad() {
    super.viewDidLoad()
        
        slider_view.isUserInteractionEnabled = false
        slider_view.value = 0.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAudioFromURL(_URL: url)
    }
    
    @IBAction func play_btn(_ sender: AnyObject) {
        getAudioFromURL(_URL: url)
    }
    
    var timerObject = Timer()
    var audio = YMCAudioPlayer()
    func getAudioFromURL(_URL: String) {
        
        let checkFileExists =  isFileExists(url: _URL)
        let filename = filenameFromURL(url: _URL)
        
        // FILEPATH
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent(filename)!.path
        
        if checkFileExists == true {
            print("FILE AVAILABLE")
            
            // PLAYING STARTING AUDIO
            audio.initPlayer(filePath as String, fileExtension: nil)
            audio.playAudio()
            
            timerObject = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(PlayVC.updateProgress), userInfo: nil, repeats: true)
            
        }else{
            print("FILE NOT AVAILABLE")
            
            UIApplication.shared.isIdleTimerDisabled = true
            showProgressHUD()
            
            self.sharedDownloadManager = TCBlobDownloadManager.sharedInstance()
            let path1 = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String)
            
            self.sharedDownloadManager.startDownload(with: URL(string: _URL)!, customPath: path1, firstResponse: nil,
                                                     
                                                     progress: { (receivedLength, totalLength, remainingTime, progress) -> Void in
                                                        
                                                        self.updateProgrssbar(progress: progress, lbl_string: "Downloading")
                                                        
                }, error: { (error) -> Void in
                    
                    self.hideProgressHUD()
                    UIApplication.shared.isIdleTimerDisabled = false
                    self.displayAlertMessage(messageAlert: (error?.localizedDescription)!)
                    
                }, complete: { (downloadFinished, pathToFile) -> Void in
                    
                    if downloadFinished == true {
                        self.hideProgressHUD()
                        UIApplication.shared.isIdleTimerDisabled = false
                        
                        let enterValue = NSEntityDescription.insertNewObject(forEntityName: "Download", into: context)
                        enterValue.setValue(filename, forKey: "file_name")
                        do{ try context.save() } catch _ { }
                        
                        // PLAYING STARTING AUDIO
                        self.audio.initPlayer(filePath as String, fileExtension: nil)
                        self.audio.playAudio()
                        
                        self.timerObject = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(PlayVC.updateProgress), userInfo: nil, repeats: true)
                        
                    }
                    
                    print(pathToFile)
                    
            })
            
        }
        
    }
    
    
    @IBOutlet var slider_view: UISlider!
    @IBOutlet var remain_time_lbl: UILabel!
    func updateProgress() {
        
        let currentTime = audio.getCurrentAudioTime()
        let durationTime = audio.getAudioDuration()
        let percentage = Float(currentTime) / Float(durationTime)
        slider_view.value = Float(percentage)
        
        // Remaining Time
        let remainingTime = durationTime - currentTime
        let remainingHour_ = abs(Int(remainingTime)/3600)
        let remainingMinute_ = abs(Int((remainingTime/60).truncatingRemainder(dividingBy: 60)))
        let remainingSecond_ = abs(Int(remainingTime.truncatingRemainder(dividingBy: 60)))
        let remainingHour = remainingHour_ > 9 ? "\(remainingHour_)" : "0\(remainingHour_)"
        let remainingMinute = remainingMinute_ > 9 ? "\(remainingMinute_)" : "0\(remainingMinute_)"
        let remainingSecond = remainingSecond_ > 9 ? "\(remainingSecond_)" : "0\(remainingSecond_)"
        
        if currentTime >= 3600 {
            let remaining_time = "\(remainingHour):\(remainingMinute):\(remainingSecond)"
            remain_time_lbl.text = "-\(remaining_time)"
        }else{
            let remaining_time = "\(remainingMinute):\(remainingSecond)"
            remain_time_lbl.text = "-\(remaining_time)"
        }
        
        // Current Time
        let hour_   = abs(Int(currentTime)/3600)
        let minute_ = abs(Int((currentTime/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(currentTime.truncatingRemainder(dividingBy: 60)))
        let hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        let current_time = "\(hour):\(minute):\(second)"
        
        // Duration Time
        let durationHour_ = abs(Int(durationTime)/3600)
        let durationMinute_ = abs(Int((durationTime/60).truncatingRemainder(dividingBy: 60)))
        let durationSecond_ = abs(Int(durationTime.truncatingRemainder(dividingBy: 60)))
        let durationHour = durationHour_ > 9 ? "\(durationHour_)" : "0\(durationHour_)"
        let durationMinute = durationMinute_ > 9 ? "\(durationMinute_)" : "0\(durationMinute_)"
        let durationSecond = durationSecond_ > 9 ? "\(durationSecond_)" : "0\(durationSecond_)"
        let duration_time = "\(durationHour):\(durationMinute):\(durationSecond)"
        
        if current_time >= duration_time {
            timerObject.invalidate()
            slider_view.value = 0.0
            audio.stopAudio()
            
            if currentTime >= 3600 {
                remain_time_lbl.text = "-00:00:00"
            }else{
                remain_time_lbl.text = "-00:00"
            }
            
        }

    }
    
    @IBAction func cancel_btn(_ sender: AnyObject) {
        container.isHidden = true
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
