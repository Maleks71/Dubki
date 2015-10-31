//
//  PlacePickerViewController.swift
//  Dubki
//
//  Created by Alexander Morenko on 29.10.15.
//  Copyright © 2015 Alexander Morenko. All rights reserved.
//

import UIKit


class CampusPickerViewController: UIViewController {

    let campuses = RouteDataModel.sharedInstance.campuses
    
    var setCampus: Int?
    
    var selectedCampus: Dictionary<String, AnyObject>? {
        didSet {
            if let campus = selectedCampus {
                selectedCampusIndex = (campus["id"] as? Int)! - 1
            }
        }
    }
    var selectedCampusIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Table View Delegate
extension CampusPickerViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //Other row is selected - need to deselect it
        if let index = selectedCampusIndex {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
            cell?.accessoryType = .None
        }
        
        selectedCampus = campuses![indexPath.row] as? Dictionary<String, AnyObject>
        
        //update the checkmark for the current row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
    }
}

extension CampusPickerViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campuses!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaceCell", forIndexPath: indexPath)
        
        let campus = campuses![indexPath.row] as! Dictionary<String, AnyObject>
        
        cell.textLabel?.text = campus["title"] as? String
        cell.detailTextLabel?.text = campus["description"] as? String
        
        return cell;
    }
}
