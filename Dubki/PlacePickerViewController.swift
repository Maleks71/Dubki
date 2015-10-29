//
//  PlacePickerViewController.swift
//  Dubki
//
//  Created by Alexander Morenko on 29.10.15.
//  Copyright © 2015 Alexander Morenko. All rights reserved.
//

import UIKit


class PlacePickerViewController: UIViewController {

    let places = ["Дубки", "Строгино", "Центр"]
    let subways = ["Общежитие",  "м. Строгино", "м. Центр"]
    
    var label: UILabel?
    var selectedPlace:String? {
        didSet {
            if let place = selectedPlace {
                selectedPlaceIndex = places.indexOf(place)!
            }
        }
    }
    var selectedPlaceIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Table View Delegate
extension PlacePickerViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //Other row is selected - need to deselect it
        if let index = selectedPlaceIndex {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
            cell?.accessoryType = .None
        }
        
        selectedPlace = places[indexPath.row]
        
        //update the checkmark for the current row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
    }
}

extension PlacePickerViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaceCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = places[indexPath.row]
        cell.detailTextLabel?.text = subways[indexPath.row]
        
        return cell;
    }
}
