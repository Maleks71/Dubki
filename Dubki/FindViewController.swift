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
    
    var fromCampus: Dictionary<String, AnyObject>? {
        didSet {
            if fromCampus != nil && fromLabel != nil {
                fromLabel.text = fromCampus!["title"] as? String
            }
        }
    }
    var toCampus: Dictionary<String, AnyObject>? {
        didSet {
            if toCampus != nil && toLabel != nil {
                toLabel.text = toCampus!["title"] as? String
            }
        }
    }
    var when: NSDate? {
        didSet {
            if when != nil && whenLabel != nil {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                whenLabel.text = dateFormatter.stringFromDate(when!)
            }
        }
    }
    
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
//                campusPickerViewController.selectedCampus = fromCampus
                campusPickerViewController.setCampus = 1
            }
        }
        if segue.identifier == "ToCampusPick" {
            if let campusPickerViewController = segue.destinationViewController as? CampusPickerViewController {
//                campusPickerViewController.selectedCampus = toCampus
                campusPickerViewController.setCampus = 2
            }
        }
//        if segue.identifier == "WhenPick" {
//            if let timePickerViewController = segue.destinationViewController as? TimePickerViewController {
//                if when != nil {
//                    timePickerViewController.selectedDate = when!
//                }
//            }
//        }
    }

    @IBAction func cancelSelect(segue:UIStoryboardSegue) {
        // not action for cancel
    }
    
    @IBAction func doneCampuseSelect(segue:UIStoryboardSegue) {
        if let campusPickerViewController = segue.sourceViewController as? CampusPickerViewController {
            //print(campusPickerViewController.selectedPlace)
            if let setCampus = campusPickerViewController.setCampus {
                if setCampus == 1 {
                    fromCampus = campusPickerViewController.selectedCampus
                } else {
                    toCampus = campusPickerViewController.selectedCampus
                }
            }
        }
    }

    @IBAction func doneTimeSelect(segue:UIStoryboardSegue) {
        if let timePickerViewController = segue.sourceViewController as? TimePickerViewController {
            //print(timePickerViewController.selectedDate)
            when = timePickerViewController.selectedDate
        }
    }

}

