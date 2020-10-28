//
//  Alarm.swift
//  Dynamic
//
//  Created by Brandon Baker on 4/30/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import MapKit
import MediaPlayer
import FirebaseFirestore

class Alarm : Codable {
    
    var id : String
    var name : String
    var arrivalTime : Date
    var readyTime : Double
    var trips : [String] = []
    var enabled : Bool
    var shouldSoundWhenPassed = false
    
    var sound : Sound
    var volume : Volume
    var repeating : [RepeatDay]
    var snooze : Snooze
    
    var nextNotification: ScheduledNotification? {
        get {
            guard enabled,
                let expiration = getNextNotification(),
                let token = LocalStorage.fcmToken
                 else { return nil }
            
            return ScheduledNotification(alarm: self,
                                         registrationToken: token,
                                         expiration: expiration)
        }
    }
    
    func setSnoozeAlarm() {
        guard enabled, let token = LocalStorage.fcmToken else { return }
        
        let expiration = 300
        let notification = ScheduledNotification(alarm: self, registrationToken: token, expiration: expiration).getDict()
        
        db.collection("alarms").document(self.id).setData(notification, merge: true)
    }
    
    var wakeUpTime : Date {
        get {
            var totalBufferTime : Double = travelTime
            totalBufferTime += readyTime
            return self.arrivalTime.addingTimeInterval(-totalBufferTime * 60)
        }
    }
    
    var travelTime : Double {
        get {
            var totalBufferTime : Double = 0
            if let trips = tripObjects {
                trips.forEach {
                    totalBufferTime += $0.travelTime ?? 0
                    totalBufferTime += $0.bufferTime
                }
            }
            return totalBufferTime
        }
    }
    
    var tripObjects : [Trip]? {
        get {
            let trips = LocalStorage.savedTrips.filter { trip in
                self.trips.contains(trip.id)
            }
            print("tripObjects\(trips)")
            return trips
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, arrivalTime, readyTime, trips, name, sound, volume, repeating, snooze, enabled, shouldSoundWhenPassed
    }
    
    init(name: String, arrivalTime: Date, readyTime: Double) {
        self.name = name
        self.id = UUID().uuidString
        self.arrivalTime = arrivalTime
        self.readyTime = readyTime
        self.sound = .alarm_clock_classic
        self.volume = .high
        self.repeating = []
        self.snooze = .enabled
        self.enabled = true
    }
    
    static func refetchActiveAlarmData() {
        ScheduledNotification.registerBackgroundTask()
        let activeAlarms = LocalStorage.savedAlarms.filter { $0.enabled }
        print("fetching data for \(activeAlarms.count) active alarms")
        activeAlarms.forEach { alarm in
            guard let trips = alarm.tripObjects, trips.count > 0 else {
                print("no trips attached - saving alarm")
                alarm.saveAlarm()
                return
            }
            trips.forEach { trip in
                trip.updateTravelTime(alarm: alarm)
            }
        }
    }
    
    func getDayAbbreviationString() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
        RepeatDay.allCases.forEach { day in
            if repeating.contains(where: { $0.rawValue == day.rawValue }) {
                attributedString.bold(day.getAbbreviation())
            } else {
                attributedString.light(day.getAbbreviation())
            }
            attributedString.bold(" ")
        }
        return attributedString
    }
    
    func addTrip(trip: Trip) {
        LocalStorage.savedTrips.append(trip)
        self.trips.append(trip.id)
        saveAlarm()
    }
    
    func soundAlarm(_ count: Int) {
        var volume : Float = self.volume.getValue()
        let count : Float = Float(count)
        if self.volume == .ascending {
            volume = volume + (0.1 * count)
        } else if self.volume == .descending {
            volume = volume - (0.1 * count)
        }
        SoundManager.instance.playSound(alarm: self, volume: volume)
    }
    
    func updateTrip(trip: Trip) {
        guard let tripIndex = LocalStorage.savedTrips.firstIndex(where: {$0.id == trip.id}) else { return }
        LocalStorage.savedTrips[tripIndex] = trip
        saveAlarm()
    }
    
}


