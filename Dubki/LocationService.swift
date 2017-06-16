//
//  LocationService.swift
//  Dubki
//
//  Created by Игорь Моренко on 13.10.15.
//  Copyright © 2015-2017 LionSoft LLC. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationServiceDelegate {
    func locationDidUpdate(_ service: LocationService, location: CLLocation)
    func didFailWithError(_ service: LocationService, error: Error)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    
    var delegate: LocationServiceDelegate?

    fileprivate let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestLocation() {
        if #available(iOS 8.0, *) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 9.0, *) {
            locationManager.requestLocation()
        } else {
            // Fallback on earlier versions
            locationManager.startUpdatingLocation()
        }
    }

    // MARK: - CoreLocation Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            //print("Current location: \(location)")
            delegate?.locationDidUpdate(self, location: location)
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("Error finding location: \(error.localizedDescription)")
        delegate?.didFailWithError(self, error: error)
    }
}
