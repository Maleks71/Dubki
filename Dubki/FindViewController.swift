//
//  ViewController.swift
//  Dubki
//
//  Created by Alexander Morenko on 29.10.15.
//  Copyright © 2015 Alexander Morenko. All rights reserved.
//

import UIKit

// view controller for input of find parameter
class FindViewController: UITableViewController {

    @IBOutlet weak var directionSegmentControl: UISegmentedControl!
    @IBOutlet weak var campusLabel: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var fortuneQuoteLabel: UILabel!
    
    // variable of view controller
    
    // selected campus
    var campus: Dictionary<String, AnyObject>? {
        didSet {
            // after set value of when need set label text
            if campusLabel != nil {
                if campus != nil {
                    campusLabel.text = campus!["title"] as? String
                } else {
                    campusLabel.text = ""
                }
            }
        }
    }
    
    // selected end date
    var when: NSDate? {
        didSet {
            // after set value of when need set label text
            if whenLabel != nil {
                if when != nil {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    whenLabel.text = dateFormatter.stringFromDate(when!)
                } else {
                    whenLabel.text = NSLocalizedString("Now", comment: "")
                }
            }
        }
    }
    
    let fortuneQuotes = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("FortuneQuotes", ofType: "plist")!)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set rounded border button
        //campusButton.layer.cornerRadius = 5
        //campusButton.layer.borderWidth = 1
        //campusButton.layer.borderColor = UIColor.blueColor().CGColor
        
        // clear campus TODO: get from setting or location
        campus = RouteDataModel.sharedInstance.campuses![2] as? Dictionary<String, AnyObject>
        
        //fromToLabel = tableView.headerViewForSection(1)?.textLabel
        //fromToLabel?.text = NSLocalizedString("ToCampus", comment: "").uppercaseString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // generate randomize int from mil to max
    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    // before view on screen for update fortune quote
    override func viewWillAppear(animated: Bool) {
        let fq = randomInt(0, max: ((fortuneQuotes?.count)! - 1))
        fortuneQuoteLabel.text = fortuneQuotes![fq] as? String
    }

    // when direction segment change value
    @IBAction func directionValueChanged(sender: AnyObject) {
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "RouteShow" {
            // посторить маршрут
            RouteDataModel.sharedInstance.calculateRoute(directionSegmentControl.selectedSegmentIndex, campus: campus, when: when)
            //tabBarController.selectedIndex = 1 // Route Tab
        }
        
        if segue.identifier == "CampusPick" {
            if let campusPickerViewController = segue.destinationViewController as? CampusPickerViewController {
                campusPickerViewController.selectedCampusIndex = (campus!["id"] as? Int)! - 2
            }
        }

        if segue.identifier == "TimePick" {
            if let timePickerViewController = segue.destinationViewController as? TimePickerViewController {
                timePickerViewController.selectedDate = when
            }
        }
    }

    
    // when press button done on campus picker view controller
    @IBAction func unwindWithSelectedCampus(segue:UIStoryboardSegue) {
        if let campusPickerViewController = segue.sourceViewController as? CampusPickerViewController, campusIndex = campusPickerViewController.selectedCampusIndex {
                campus = RouteDataModel.sharedInstance.campuses![campusIndex + 1] as? Dictionary<String, AnyObject>
        }
    }

    // when press button done on time picker view controller
    @IBAction func unwindSelectedTime(segue:UIStoryboardSegue) {
        if let timePickerViewController = segue.sourceViewController as? TimePickerViewController {
            //print(timePickerViewController.selectedDate)
            when = timePickerViewController.selectedDate
        }
    }

    // when press button save on settings view controller
    @IBAction func saveSettings(segue:UIStoryboardSegue) {
    }

    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Table View Data Source
    
    // заголовки секций таблицы
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0:
            return NSLocalizedString("IWantToReach", comment: "") // Я хочу добраться
        case 1:
            if directionSegmentControl.selectedSegmentIndex == 0 {
                return NSLocalizedString("ToCampus", comment: "") // в Кампус
            } else {
                return NSLocalizedString("FromCampus", comment: "") // из Кампуса
            }
        case 2:
            return NSLocalizedString("When", comment: "") // Когда
        default:
            return ""
        }
    }
}

