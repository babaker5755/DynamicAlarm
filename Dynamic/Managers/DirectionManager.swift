//
//  MapManager.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/2/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import MapKit

class DirectionManager : NSObject, CLLocationManagerDelegate {
    
    let searchRadius : Double = 2
    
    static var instance = DirectionManager()
    
    var userLocation : CLLocation? = nil
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        resetUserLocation()
    }
    
    func resetUserLocation() {
        locationManager.requestLocation()
    }
    
    func searchString(_ searchText: String, completion: @escaping (([Location]) -> Void)) {
        
        guard !searchText.isEmpty else { return }
        
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = searchText
        request.resultTypes = .address
        if let userLocation = self.userLocation {
            let region = MKCoordinateRegion(center: userLocation.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: searchRadius, longitudeDelta: searchRadius))
            request.region = region
        }
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else { return }
            let locations = response.mapItems.map { mapItem in
                return Location(name: mapItem.name,
                                latitude: mapItem.placemark.location?.coordinate.latitude ?? 0,
                                longitude: mapItem.placemark.location?.coordinate.longitude ?? 0)
            }
            completion(locations)
        }
    }
    
    static func getEstimatedTravelTime(transportType: TransportType, start: Location, end: Location, completion: @escaping ((Double?) -> Void)) {
        
        let request = MKDirections.Request()
        let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: start.latitude,
                                                                       longitude: start.longitude))
        request.source = MKMapItem(placemark: sourcePlacemark)
        
        let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: end.latitude,
                                                                                  longitude: end.longitude))
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.requestsAlternateRoutes = false
        request.transportType = transportType == .automobile ? .automobile : .walking
        MKDirections(request: request).calculate() { (response, error) in
          if let error = error {
            print(error.localizedDescription)
            return
          }
          if let route = response?.routes.first {
            completion(route.expectedTravelTime)
          }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.userLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }

}
