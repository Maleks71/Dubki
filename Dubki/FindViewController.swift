//
//  FindViewController.swift
//  Dubki
//
//  Created by Alexander Morenko on 29.10.15.
//  Copyright © 2015 LionSoft, LLC. All rights reserved.
//

import UIKit
import CoreLocation

// view controller for input of find parameter
class FindViewController: UITableViewController, LocationServiceDelegate {

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
                    whenLabel.text = when!.string("dd MMM HH:mm")
                } else {
                    whenLabel.text = NSLocalizedString("Now", comment: "")
                }
            }
        }
    }
    
    let fortuneQuotes = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("FortuneQuotes", ofType: "plist")!)
    
    let locationService = LocationService()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationService.delegate = self
        locationService.requestLocation()

        setDefaultCampus()
        
        // set rounded border button
        //campusButton.layer.cornerRadius = 5
        //campusButton.layer.borderWidth = 1
        //campusButton.layer.borderColor = UIColor.blueColor().CGColor
        
        //fromToLabel = tableView.headerViewForSection(1)?.textLabel
        //fromToLabel?.text = NSLocalizedString("ToCampus", comment: "").uppercaseString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setDefaultCampus() {
        // clear campus TODO: get from setting or location
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.synchronize()
        var defaultCampus = userDefaults.integerForKey("campus")
        if defaultCampus == 0 {
            defaultCampus = 2 // Strogino
        }
        campus = RouteDataModel.sharedInstance.campuses![defaultCampus]
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
            if let campusPicker = segue.destinationViewController as? CampusPickerViewController {
                campusPicker.selectedCampusIndex = (campus!["id"] as! Int) - 2
            }
        }

        if segue.identifier == "TimePick" {
            if let timePicker = segue.destinationViewController as? TimePickerViewController {
                timePicker.selectedDate = when
            }
        }

        if segue.identifier == "SettingsPick" {
            if let settings = segue.destinationViewController as? SettingsTableViewController {
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.synchronize()
                let campusIndex = userDefaults.integerForKey("campus")
                settings.campusIndex = campusIndex == 0 ? 0 : campusIndex - 1
                settings.autolocation = userDefaults.boolForKey("autolocation")
                settings.autoload = userDefaults.boolForKey("autoload")
            }
        }
    }

    
    // when press button done on campus picker view controller
    @IBAction func unwindWithSelectedCampus(segue:UIStoryboardSegue) {
        if let campusPicker = segue.sourceViewController as? CampusPickerViewController, campusIndex = campusPicker.selectedCampusIndex {
                campus = RouteDataModel.sharedInstance.campuses![campusIndex + 1]
        }
    }

    // when press button done on time picker view controller
    @IBAction func unwindSelectedTime(segue:UIStoryboardSegue) {
        if let timePicker = segue.sourceViewController as? TimePickerViewController {
            //print(timePickerViewController.selectedDate)
            when = timePicker.selectedDate
        }
    }

    // when press button save on settings view controller
    @IBAction func saveSettings(segue:UIStoryboardSegue) {
        if let settings = segue.sourceViewController as? SettingsTableViewController {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setInteger((settings.campusIndex! + 1), forKey: "campus")
            userDefaults.setBool(settings.autolocation!, forKey: "autolocation")
            userDefaults.setBool(settings.autoload!, forKey: "autoload")
            userDefaults.synchronize()
        }
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
            return NSLocalizedString("ThePlannedTime", comment: "") // Планируемое время
        default:
            return ""
        }
    }
    
    // MARK: - Location Service Delegate
    
    func locationDidUpdate(service: LocationService, location: CLLocation) {
        //print("Current location: \(location)")
        let locationLatitude = location.coordinate.latitude
        let locationLongitude = location.coordinate.longitude
        
        var findItem: Dictionary<String, AnyObject>? = nil
        for item in RouteDataModel.sharedInstance.campuses! {
            let latitude = Double(item["lat"] as! String)
            let longitude = Double(item["lon"] as! String)
            // Градусы   Дистанция
            // --------- ----------
            // 1         111 km
            // 0.1       11.1 km
            // 0.01      1.11 km
            //*0.001     111 m
            // 0.0001    11.1 m
            // 0.00001   1.11 m
            // 0.000001  11.1 cm
            // 0.0005 - 55.5m
            if abs(locationLatitude - latitude!) < 0.001 && abs(locationLongitude - longitude!) < 0.001 {
                findItem = item
                break;
            }
        }
        if findItem != nil {
            //print("Find Current Campus: \(findItem!)")
            let campusId = findItem!["id"] as! Int
            if campusId == 1 {
                // dormitories
                directionSegmentControl.selectedSegmentIndex = 0 // из Дубков
                setDefaultCampus()
            } else {
                // campus
                directionSegmentControl.selectedSegmentIndex = 1 // в Дубки
                campus = findItem
            }
        }
    }
    
    func didFailWithError(service: LocationService, error: NSError) {
        // show error alert
        if #available(iOS 8.0, *) {
            let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            errorAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                errorAlert.dismissViewControllerAnimated(true, completion: nil)
            }))
            presentViewController(errorAlert, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            let alertView = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
    }
}
