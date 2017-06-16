//
//  TimePickerViewController.swift
//  Dubki
//
//  Created by Alexander Morenko on 29.10.15.
//  Copyright © 2015-2017 LionSoft, LLC. All rights reserved.
//

import UIKit

class TimePickerViewController: UIViewController {
    
//    let lessonTitles = ["I (9:00)", "II (10:30)", "III (12:10)", "IV (13:40)", "V (15:10)", "VI (16:40)", "VII (18:10)", "VIII (19:40)"]
    let lessonTimes = ["I":"09:00", "II":"10:30", "III":"12:10", "IV":"13:40", "V":"15:10", "VI":"16:40", "VII":"18:10", "VIII":"19:40"]

    var departureTime: Date?
    var arrivalTime: Date?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var lessonView: UIView!
    @IBOutlet weak var departureArrivalSegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        datePicker.minimumDate = Date()
        datePicker.maximumDate = Date().dateByAddingDay(30) // +30 day
        if departureTime != nil {
            datePicker.date = departureTime!
            departureArrivalSegmentControl.selectedSegmentIndex = 0
        }
        if arrivalTime != nil {
            datePicker.date = arrivalTime!
            departureArrivalSegmentControl.selectedSegmentIndex = 1
        }
        lessonView.isHidden = departureArrivalSegmentControl.selectedSegmentIndex == 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func departureArrivalValueChange(_ sender: AnyObject) {
        lessonView.isHidden = departureArrivalSegmentControl.selectedSegmentIndex == 0
    }
    
    @IBAction func lessonButtonPress(_ sender: UIButton) {
        // change time for lesson
        let lessonTime = lessonTimes[(sender.titleLabel?.text)!]
        let date = datePicker.date.dateByWithTime(lessonTime!)!

        if date.compare(Date()) == .orderedDescending {
            datePicker.date = date
        } else {
            // next day
            datePicker.date = date.dateByAddingDay(1)!
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SaveSelectedTime" {
            if departureArrivalSegmentControl.selectedSegmentIndex == 0 {
                departureTime = datePicker.date
                arrivalTime = nil
            } else {
                departureTime = nil
                arrivalTime = datePicker.date
            }
        }
    }
}
