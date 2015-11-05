//
//  TimePickerViewController.swift
//  Dubki
//
//  Created by Alexander Morenko on 29.10.15.
//  Copyright © 2015 Alexander Morenko. All rights reserved.
//

import UIKit

class TimePickerViewController: UIViewController {
    
//    let lessonTitles = ["I (9:00)", "II (10:30)", "III (12:10)", "IV (13:40)", "V (15:10)", "VI (16:40)", "VII (18:10)", "VIII (19:40)"]
    let lessonTimes = ["I":" 09:00", "II":" 10:30", "III":" 12:10", "IV":" 13:40", "V":" 15:10", "VI":" 16:40", "VII":" 18:10", "VIII":" 19:40"]

    var selectedDate: NSDate?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        datePicker.minimumDate = NSDate()
        if selectedDate != nil {
            datePicker.date = selectedDate!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func lessonButtonPress(sender: UIButton) {
        // change time for lesson
        let lessonTime = lessonTimes[(sender.titleLabel?.text)!]

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.stringFromDate(datePicker.date) + lessonTime!
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let date = dateFormatter.dateFromString(dateString)!
        if date.compare(NSDate()) == .OrderedDescending {
            datePicker.date = date
        } else {
            datePicker.date = NSDate()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SaveSelectedTime" {
            selectedDate = datePicker.date
        }
    }
}
