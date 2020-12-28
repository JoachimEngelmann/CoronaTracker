//
//  locationProviderGPS.swift
//  Corona Index
//
//  Created by Joachim Engelmann on 28.10.20.
//  Copyright © 2020 Joachim Engelmann. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class LocationProvider: NSObject, CLLocationManagerDelegate{
    var locationManager: CLLocationManager!
    
    private var completion: ((CLLocationCoordinate2D) -> Void)?
    
    func aquireCoordinates(name: String, completion: @escaping (CLLocationCoordinate2D) -> Void = { _ in }) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(name) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                return
            }
            completion(location.coordinate)
        }
    }
    
    func aquireGpsPosition(completion: @escaping (CLLocationCoordinate2D) -> Void = { _ in }) {
        self.completion = completion
        
        if( locationManager == nil){
            locationManager = CLLocationManager()
        }
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        locationManager.stopUpdatingLocation()
        
        self.completion?(locValue)
    }
}

