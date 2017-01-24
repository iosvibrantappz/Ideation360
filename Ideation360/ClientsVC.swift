//
//  ClientsVC.swift
//  Ideation360
//
//  Created by Sukhwinder Singh on 14/12/16.
//  Copyright © 2016 Gurpreet Singh. All rights reserved.
//

import UIKit
import CoreData

var AssignmentsDic: [Dictionary<String, String>] = []
var selectedAssignment = Int()
class ClientsVC: AppContentFile, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var clients_tbl: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        clients_tbl.bounces = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
                
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AssignmentsDic.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAssignment = indexPath.row
        jump_to_storyboard(identifier: "MyIdeasVC")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ClientsCell
        cell._textLabel.text = AssignmentsDic[indexPath.row]["company"]
        return cell
    }
    
    @IBAction func ideation360_btn(_ sender: AnyObject) {
        goToWebPortal()
    }
    
    @IBAction func back_btn(_ sender: AnyObject) {
        jump_to_storyboard(identifier: "LoginVC")
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
