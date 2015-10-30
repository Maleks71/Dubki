//
//  ViewController.swift
//  Dubki
//
//  Created by Alexander Morenko on 29.10.15.
//  Copyright © 2015 Alexander Morenko. All rights reserved.
//

import UIKit

class FindViewController: UIViewController {

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        clearAll(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clearAll(sender: AnyObject) {
        fromLabel.text = ""
        toLabel.text = ""
        whenLabel.text = ""
    }

    @IBAction func swapPlaces(sender: AnyObject) {
        let place = fromLabel.text
        fromLabel.text = toLabel.text
        toLabel.text = place
    }
    
    @IBAction func goButtonPress(sender: AnyObject) {
        if let tabBarController = self.tabBarController {
            //print(tabBarController.selectedIndex)
            tabBarController.selectedIndex = 1 // Route Tab
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FromCampusPick" {
            if let campusPickerViewController = segue.destinationViewController as? CampusPickerViewController {
                campusPickerViewController.label = fromLabel
            }
        }
        if segue.identifier == "ToCampusPick" {
            if let campusPickerViewController = segue.destinationViewController as? CampusPickerViewController {
                campusPickerViewController.label = toLabel
            }
        }
   }

    @IBAction func cancelSelect(segue:UIStoryboardSegue) {
        // not action for cancel
    }
    
    @IBAction func doneCampuseSelect(segue:UIStoryboardSegue) {
        if let campusPickerViewController = segue.sourceViewController as? CampusPickerViewController {
            //print(campusPickerViewController.selectedPlace)
            if let label = campusPickerViewController.label {
                if let campus = campusPickerViewController.selectedCampus {
                    label.text = campus["title"] as? String
                }
            }
        }
    }

    @IBAction func doneTimeSelect(segue:UIStoryboardSegue) {
        if let timePickerViewController = segue.sourceViewController as? TimePickerViewController {
            //print(timePickerViewController.datePicker.date)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            whenLabel.text = dateFormatter.stringFromDate(timePickerViewController.datePicker.date)
        }
    }

}

