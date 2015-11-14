//
//  RouteTableViewController.swift
//  Dubki
//
//  Created by Alexander Morenko on 29.10.15.
//  Copyright © 2015 LionSoft, LLC. All rights reserved.
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
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let routeStep = routeDataModel.route[indexPath.row]
        if routeStep.url != nil {
            UIApplication.sharedApplication().openURL(NSURL(string: routeStep.url!)!)
        }
        if routeStep.map != nil {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            performSegueWithIdentifier("RouteDetail", sender: cell)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return routeDataModel.route.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let routeStep = routeDataModel.route[indexPath.row]
        if routeStep.type == .Train {
            return 120
        } else {
            return 66
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let routeStep = routeDataModel.route[indexPath.row]

        if routeStep.type == .Train {
            let cell = tableView.dequeueReusableCellWithIdentifier("TrainRouteCell", forIndexPath: indexPath) as! TrainRouteStepTableViewCell
            
            // Configure the cell...
            cell.titleLabel?.text = routeStep.title
            cell.detailLabel?.text = routeStep.detail

            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("RouteCell", forIndexPath: indexPath)

            // Configure the cell...
            cell.textLabel?.text = routeStep.title
            cell.detailTextLabel?.text = routeStep.detail
            if routeStep.url != nil || routeStep.map != nil {
                cell.accessoryType = .DetailButton
            } else {
                cell.accessoryType = .None
            }
            return cell
        }
    }

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
        if segue.identifier == "RouteDetail" {
            if let detailViewController = segue.destinationViewController as? DetailViewController {
                if let cell = sender as? UITableViewCell {
                    let indexPath = tableView.indexPathForCell(cell)
                    let routeStep = routeDataModel.route[indexPath!.row]
                    detailViewController.imageName = routeStep.map
                }
            }
        }
    }

}

class TrainRouteStepTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
}
