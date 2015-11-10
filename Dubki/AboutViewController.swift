//
//  AboutViewController.swift
//  Dubki
//
//  Created by Игорь Моренко on 05.11.15.
//  Copyright © 2015 LionSoft, LLC. All rights reserved.
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
        //let money_url = "https://money.yandex.ru/embed/shop.xml?account=41001824209175&quickpay=shop&payment-type-choice=on&writer=seller&targets=Dubki&targets-hint=&default-sum=100&button-text=03&comment=on&hint=&successURL="
        let money_url = "http://yasobe.ru/na/dubki_app"
        UIApplication.sharedApplication().openURL(NSURL(string: money_url)!)
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
