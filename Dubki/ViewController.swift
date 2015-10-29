//
//  ViewController.swift
//  Dubki
//
//  Created by Alexander Morenko on 29.10.15.
//  Copyright © 2015 Alexander Morenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FromPlacePick" {
            if let placePickerViewController = segue.destinationViewController as? PlacePickerViewController {
                placePickerViewController.label = fromLabel
            }
        }
        if segue.identifier == "ToPlacePick" {
            if let placePickerViewController = segue.destinationViewController as? PlacePickerViewController {
                placePickerViewController.label = toLabel
            }
        }
   }

    @IBAction func cancelSelect(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func donePlaceSelect(segue:UIStoryboardSegue) {
        if let placePickerViewController = segue.sourceViewController as? PlacePickerViewController {
            print(placePickerViewController.selectedPlace)
            if let label = placePickerViewController.label {
                label.text = placePickerViewController.selectedPlace
            }
        }
    }

    @IBAction func doneTimeSelect(segue:UIStoryboardSegue) {
        if let timePickerViewController = segue.sourceViewController as? TimePickerViewController {
            print(timePickerViewController.selectedDate)
            print(timePickerViewController.selectedTime)
            // = cityPickerViewController.selectedCity!
        }
    }

}

