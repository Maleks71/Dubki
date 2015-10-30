//
//  RouteDataModel.swift
//  Dubki
//
//  Created by Alexander Morenko on 30.10.15.
//  Copyright © 2015 Alexander Morenko. All rights reserved.
//

import UIKit

// Singleton Class
class RouteDataModel: NSObject {
    
    static let sharedInstance = RouteDataModel()

    var campuses: NSArray?
    
    override init() {
        super.init()
        
        // load array of campuses from resource
        let campusesPath = NSBundle.mainBundle().pathForResource("Campuses", ofType: "plist")
        campuses = NSArray(contentsOfFile: campusesPath!)
        print(campuses?.count)
        
    }
}
