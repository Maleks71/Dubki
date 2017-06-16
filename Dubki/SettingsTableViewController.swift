//
//  SettingsTableViewController.swift
//  Dubki
//
//  Created by Игорь Моренко on 04.11.15.
//  Copyright © 2015-2017 LionSoft, LLC. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var campusLabel: UILabel!
    @IBOutlet weak var autolocationSwitch: UISwitch!
    
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
            autolocationSwitch.isOn = autolocation!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // when press button done on campus picker view controller
    @IBAction func unwindWithSelectedCampus(_ segue:UIStoryboardSegue) {
        if let campusPickerViewController = segue.source as? CampusPickerViewController {
            campusIndex = campusPickerViewController.selectedCampusIndex
        }
    }

    // MARK: - Table view data source
/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
*/

/*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
*/

/*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
*/

/*
    // Override to support editing the table view.
    override func  tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
*/

/*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
*/

/*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
*/

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "CampusPick" {
            if let campusPicker = segue.destination as? CampusPickerViewController {
                campusPicker.selectedCampusIndex = campusIndex
            }
        }

        if segue.identifier == "SaveSettings" {
            autolocation = autolocationSwitch.isOn
        }
    }

}
