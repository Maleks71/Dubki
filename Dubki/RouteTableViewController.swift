//
//  RouteTableViewController.swift
//  Dubki
//
//  Created by Alexander Morenko on 29.10.15.
//  Copyright © 2015-2017 LionSoft, LLC. All rights reserved.
//

import UIKit

class RouteTableViewController: UITableViewController {
 
    // route data model
    let routeDataModel = RouteDataModel.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let routeStep = routeDataModel.route[indexPath.row]
        if  let trainStep = routeStep as? TrainStep {
            if trainStep.url != nil {
                UIApplication.shared.openURL(URL(string: trainStep.url!)!)
            }
        }
        if let onfootStep = routeStep as? OnfootStep {
            if onfootStep.map != nil {
                let cell = tableView.cellForRow(at: indexPath)
                performSegue(withIdentifier: "RouteDetail", sender: cell)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return routeDataModel.route.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let routeStep = routeDataModel.route[indexPath.row]
        if routeStep is TrainStep {
            return 120
        } else {
            return 66
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let routeStep = routeDataModel.route[indexPath.row]

        if routeStep is TrainStep {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrainRouteCell", for: indexPath) as! TrainRouteStepTableViewCell
            
            // Configure the cell...
            cell.titleLabel?.text = routeStep.title
            cell.detailLabel?.text = routeStep.detail

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath)

            // Configure the cell...
            cell.textLabel?.text = routeStep.title
            cell.detailTextLabel?.text = routeStep.detail
            if routeStep is TrainStep || routeStep is OnfootStep {
                cell.accessoryType = .detailButton
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
    }

/*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
*/

/*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        if segue.identifier == "RouteDetail" {
            if let detailViewController = segue.destination as? DetailViewController {
                if let cell = sender as? UITableViewCell {
                    let indexPath = tableView.indexPath(for: cell)
                    if let onfootStep = routeDataModel.route[indexPath!.row] as? OnfootStep {
                        detailViewController.imageName = onfootStep.map
                    }
                }
            }
        }
    }

}

class TrainRouteStepTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
}
