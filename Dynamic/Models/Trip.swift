//
//  Travel.swift
//  Dynamic
//
//  Created by Brandon Baker on 4/30/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import MapKit


protocol TripUpdateDelegate {
    func travelTimeUpdated()
}

enum TripAddResult {
  case success
  case failure
}

class Location : Codable {
    var name : String
    var latitude : Double
    var longitude : Double
    init(name: String?, latitude: Double, longitude: Double) {
        self.name = name ?? ""
        self.latitude = latitude
        self.longitude = longitude
    }
    init() {
        self.name = ""
        self.latitude = 0
        self.longitude = 0
    }
}

enum TransportType : String, Codable {
    case automobile = "Automobile"
    case walking = "Walking"
}

class Trip : Codable {
    
    var id : String
    var startAddress : Location
    var endAddress : Location
    var transportType : TransportType
    var bufferTime : Double
    var travelTime: Double? = nil

    var tripUpdateDelegate : TripUpdateDelegate?
    
    enum CodingKeys: String, CodingKey {
        case id, startAddress, endAddress, transportType, bufferTime, travelTime
    }
    
    init(alarm: Alarm, startAddress: Location, endAddress: Location, transportType: TransportType, bufferTime: Double) {
        self.id = UUID().uuidString
        self.startAddress = startAddress
        self.endAddress = endAddress
        self.bufferTime = bufferTime
        
        self.transportType = transportType == .automobile ? .automobile : .walking
        DirectionManager.getEstimatedTravelTime(transportType: transportType, start: startAddress, end: endAddress) { result in
            guard let result = result else { return }
            let timeInMinutes = result / 60
            print("estimatedTravelTime: \(timeInMinutes) minutes")
            self.travelTime = timeInMinutes
            alarm.updateTrip(trip: self)
            self.tripUpdateDelegate?.travelTimeUpdated()
        }
    }
    
    func updateTravelTime(alarm: Alarm) {
        DirectionManager.getEstimatedTravelTime(transportType: transportType, start: startAddress, end: endAddress) { result in
            guard let result = result else { return }
            let timeInMinutes = result / 60
            print("estimatedTravelTime: \(timeInMinutes) minutes")
            self.travelTime = timeInMinutes
            alarm.updateTrip(trip: self)
            self.saveTrip()
            self.tripUpdateDelegate?.travelTimeUpdated()
        }
    }
    
    // Should only be used to temporarily store travel time
    // with trip
    func saveTrip() {
        if let tripIndex = LocalStorage.savedTrips.firstIndex(where: {$0.id == self.id}) {
            // If it exists, update it
            LocalStorage.savedTrips[tripIndex] = self
        } else {
            // else create a new one
            LocalStorage.savedTrips.append(self)
        }
        
    }
    
}
