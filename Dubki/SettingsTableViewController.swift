//
//  SettingsTableViewController.swift
//  Dubki
//
//  Created by Игорь Моренко on 04.11.15.
//  Copyright © 2015 LionSoft, LLC. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var campusLabel: UILabel!
    @IBOutlet weak var autolocationSwitch: UISwitch!
    @IBOutlet weak var autoloadSwitch: UISwitch!
    
    // selected campus
    var campusIndex: Int? {
        didSet {
            // after set value of when need set label text
            if campusLabel != nil {
                if campusIndex != nil {
                    let campus = RouteDataModel.sharedInstance.campuses![campusIndex! + 1]
                    campusLabel.text = campus["title"] as? String
                } else {
                    campusLabel.text = ""
                }
            }
        }
    }
    
    // selected autolocation
    var autolocation: Bool?
    
    // selected autoload
    var autoload: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if campusIndex != nil {
            let campus = RouteDataModel.sharedInstance.campuses![campusIndex! + 1]
            campusLabel.text = campus["title"] as? String
        }
        if autolocation != nil {
            autolocationSwitch.on = autolocation!
        }
        if autoload != nil {
            autoloadSwitch.on = autoload!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // when press button done on campus picker view controller
    @IBAction func unwindWithSelectedCampus(segue:UIStoryboardSegue) {
        if let campusPickerViewController = segue.sourceViewController as? CampusPickerViewController {
            campusIndex = campusPickerViewController.selectedCampusIndex
        }
    }

    // MARK: - Table view data source
    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "CampusPick" {
            if let campusPicker = segue.destinationViewController as? CampusPickerViewController {
                campusPicker.selectedCampusIndex = campusIndex
            }
        }

        if segue.identifier == "SaveSettings" {
            autolocation = autolocationSwitch.on
            autoload = autoloadSwitch.on
        }
    }

}
