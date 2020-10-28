//
//  LocalStorage.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/1/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit

class LocalStorage {
    
    public static var fcmToken : String? {
        get {
            return UserDefaults.standard.string(forKey: "fcmToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "fcmToken")
        }
    }
    
    public static var didTakeTour : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "didTakeTour")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "didTakeTour")
        }
    }
    
    public static var shouldBeFree : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "shouldBeFree")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "shouldBeFree")
        }
    }
    
    public static var savedAlarms : [Alarm] {
        get {
            if let data = UserDefaults.standard.data(forKey: "savedAlarms") {
                do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()
                    
                    // Decode Alarm
                    let strategies = try decoder.decode([Alarm].self, from: data)
                    
                    return strategies
                } catch {
                    print("Unable to Decode Alarms (\(error))")
                }
            }
            return []
        }
        set {
            do {
                // Create JSON Encoder
                let encoder = JSONEncoder()
                
                // Encode Note
                let data = try encoder.encode(newValue)
                
                // Write/Set Data
                UserDefaults.standard.set(data, forKey: "savedAlarms")
                
            } catch {
                print("Unable to Encode Alarm (\(error))")
            }
        }
    }
    
    public static var savedTrips : [Trip] {
        get {
            if let data = UserDefaults.standard.data(forKey: "savedTrips") {
                do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()
                    
                    // Decode Alarm
                    let trips = try decoder.decode([Trip].self, from: data)
                    
                    return trips
                } catch {
                    print("Unable to Decode Trips (\(error))")
                }
            }
            return []
        }
        set {
            do {
                // Create JSON Encoder
                let encoder = JSONEncoder()
                
                // Encode Note
                let data = try encoder.encode(newValue)
                
                // Write/Set Data
                UserDefaults.standard.set(data, forKey: "savedTrips")
                
            } catch {
                print("Unable to Encode Trip (\(error))")
            }
        }
    }
}
