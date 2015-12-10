//
//  LocationController.swift
//  Double
//
//  Created by James Pacheco on 12/9/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit
import CoreLocation

class LocationController: NSObject, CLLocationManagerDelegate {
    
    static let SharedInstance = LocationController()
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    
    static func resolvePermissions() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            break
        case .NotDetermined:
            SharedInstance.locationManager.requestWhenInUseAuthorization()
        case .Denied, .Restricted:
            SharedInstance.locationManager.requestWhenInUseAuthorization()
        }
        return CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse
    }
    
    static func requestLocation() {
        SharedInstance.locationManager.requestLocation()
    }
    
    static func locationAsCityCountry(location: CLLocation, completion: (cityState: String?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            if error != nil {
                print("Geocoding error: \(error)")
            }
            guard let placemarks = placemarks where placemarks.count > 0 else {
                print("No placemarks");
                completion(cityState: nil)
                return
            }
            if let city = placemarks.first!.locality, state = placemarks.first!.administrativeArea {
                completion(cityState: "\(city), \(state)")
            } else {
                completion(cityState: nil)
            }
        }
    }
    
    static func zipAsCoordinates(cityState: String, completion: (coordinate: CLLocation?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString("\(cityState)") { (placemarks, error) -> Void in
            if error != nil {
                print("Geocoding error: \(error)")
            }
            guard let placemarks = placemarks where placemarks.count > 0 else {
                print("No placemarks");
                completion(coordinate: nil)
                return
            }
            if let location = placemarks.first!.location{
                completion(coordinate: location)
            } else {
                completion(coordinate: nil)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            NSNotificationCenter.defaultCenter().postNotificationName("locationUpdated", object: self, userInfo:  ["location" : location])
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSNotificationCenter.defaultCenter().postNotificationName("FailedToFindLocation", object: self)
        print("Failed to find location: \(error)")
    }
}
