//
//  CampusPickerViewController.swift
//  Dubki
//
//  Created by Alexander Morenko on 29.10.15.
//  Copyright © 2015 LionSoft, LLC. All rights reserved.
//

import UIKit


class CampusPickerViewController: UITableViewController {

    let campuses = RouteDataModel.sharedInstance.campuses
    
    var selectedCampusIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SaveSelectedCampus" {
            if let cell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(cell)
                selectedCampusIndex = indexPath?.row
            }
        }
    }

    // MARK: - Table View Delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //Other row is selected - need to deselect it
        if let index = selectedCampusIndex {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
            cell?.accessoryType = .None
        }
        
        //selectedCampus = campuses![indexPath.row] as? Dictionary<String, AnyObject>
        selectedCampusIndex = indexPath.row
        
        //update the checkmark for the current row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
    }

    // MARK: - Table View Data Source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campuses!.count - 1;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CampusCell", forIndexPath: indexPath)
        
        let campus = campuses![indexPath.row + 1] 
        
        cell.textLabel?.text = campus["title"] as? String
        cell.detailTextLabel?.text = campus["description"] as? String
        if indexPath.row == selectedCampusIndex {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell;
    }
}
