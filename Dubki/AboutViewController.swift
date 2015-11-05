//
//  AboutViewController.swift
//  Dubki
//
//  Created by Игорь Моренко on 05.11.15.
//  Copyright © 2015 Alexander Morenko. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        let build = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
        
        versionLabel.text = String(format: "ver. %@ (build %@)", version, build)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donatePressButton(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://lionsoft.ru")!)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
