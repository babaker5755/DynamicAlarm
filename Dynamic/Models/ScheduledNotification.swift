//
//  AlarmReference.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/13/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import FirebaseFirestore


struct ScheduledNotification: Codable {
    
    let alarm : Alarm
    let registrationToken : String
    let expiration : Int
    
    init(alarm: Alarm, registrationToken: String, expiration: Int) {
        self.alarm = alarm
        self.registrationToken = registrationToken
        self.expiration = expiration
    }
    
    func getDict() -> [String: Any] {
        
        let calendar = Calendar.current
        let wakeupComponents = calendar.dateComponents([.hour, .minute], from: alarm.wakeUpTime)
        let arrivalComponents = calendar.dateComponents([.hour, .minute], from: alarm.arrivalTime)
        let timeToDestination = calendar.dateComponents([.minute], from: wakeupComponents, to: arrivalComponents).minute!
        
        print(expiration)
        let data : [String: Any] = [
            "alarmId": alarm.id,
            "registrationToken": registrationToken,
            "expiration": expiration,
            "sound": alarm.sound.rawValue,
            "title": "Time to get up!",
            "message": "You need to get to your destination in \(timeToDestination) minutes"
        ]
        return data
    }
    
    static func updateAlarmsInDatabase() {
        
        let batch = db.batch()
        let alarms = LocalStorage.savedAlarms
        
        for alarm in alarms {
            
            guard let data = alarm.nextNotification?.getDict() else { continue }
            
            let document = db.collection("alarms").document(alarm.id)
            
            batch.setData(data, forDocument: document)
            
        }
        
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
        
        clearOldAlarms()
        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: {
            if ScheduledNotification.backgroundTask != .invalid {
                ScheduledNotification.endBackgroundTask()
            }
        })
    }
    
    
    static var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    static func registerBackgroundTask() {
        print("registered background task")
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            self.endBackgroundTask()
        }
        assert(backgroundTask != .invalid)
    }
    
    static func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    
    static func clearOldAlarms() {
        guard let token = LocalStorage.fcmToken else { return }
        
        let savedAlarms = LocalStorage.savedAlarms
        let alarmCollection = db.collection("alarms")
        
        alarmCollection.whereField("registrationToken", isEqualTo: token).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let batch = db.batch()
                for document in querySnapshot!.documents {
                    // if the alarm exists locally and disabled, remove from db
                    if let alarm = savedAlarms.first(where: { $0.id == document.documentID }) {
                        if !alarm.enabled {
                            batch.deleteDocument(alarmCollection.document(document.documentID))
                        }
                    } else {
                        // if the alarm does not exist locally, remove from db
                        batch.deleteDocument(alarmCollection.document(document.documentID))
                    }
                }
                batch.commit() { err in
                    if let err = err {
                        print("Error writing batch \(err)")
                    } else {
                        print("Batch write succeeded.")
                    }
                }
            }
        }
        
        
    }
}
