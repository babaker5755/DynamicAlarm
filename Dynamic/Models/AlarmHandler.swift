//
//  AlarmHandler.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/17/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Hero
import FirebaseFirestore

protocol AlarmHandlerDelegate {
    func showAlarmDismissalView(_ alarm: Alarm)
}

class AlarmHandler {
    
    public static var instance = AlarmHandler()
    
    var delegate : AlarmHandlerDelegate?
    
    var isAppOpen : Bool = false
    
    var alarmSoundCount : Int {
        get {
            return UserDefaults.standard.integer(forKey: "alarmSoundCount")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "alarmSoundCount")
        }
    }

    var activeAlarm : Alarm? = nil {
        didSet {
            
            guard let activeAlarm = activeAlarm else { return }
            
            if !SoundManager.instance.isPlaying() {
                activeAlarm.soundAlarm(1)
            }
            
            if let delegate = delegate {
                delegate.showAlarmDismissalView(activeAlarm)
                isAppOpen = true
            }
            spamAlarm()
        }
    }
    
    func sendAlarm() {
        guard let alarmId = activeAlarm?.id else { return }
        let url = URL(string: Secrets.sendAlarmRoute)!
        
        var request = URLRequest(url: url)
        let json: [String: String] =  ["id":alarmId]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            self.spamAlarm()
        }
        task.resume()
    }
    
    func spamAlarm() {
        guard let alarm = self.activeAlarm else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + alarm.sound.duration(), execute: {
            print("alarmSoundcount\(self.alarmSoundCount)")
            guard let alarm = self.activeAlarm, self.alarmSoundCount < 50 else {
                self.resetAlarm()
                return
            }
            self.alarmSoundCount += 1
            if self.isAppOpen {
                print("app is open")
                alarm.soundAlarm(self.alarmSoundCount)
                self.spamAlarm()
            } else {
                print("app is not open - checking db for alarm")
                db.collection("alarms").document(alarm.id).getDocument { (document, error) in
                    if let document = document, document.exists {
                        print("app is not open - alarm exists in db, sending network call to receive new notification")
                        self.sendAlarm()
                    } else {
                        print("does not exist in db, stopping alarm")
                        SoundManager.instance.stopSound()
                    }
                }
            }
        })
    }
    
    func resetAlarm() {
        guard let alarm = activeAlarm else {
            SoundManager.instance.stopSound()
            return
        }
        if alarm.repeating.isEmpty {
            alarm.enabled = false
            alarm.saveAlarm()
        }
        activeAlarm = nil
        alarmSoundCount = 0
        activeAlarm?.shouldSoundWhenPassed = true
        Alarm.refetchActiveAlarmData()
        SoundManager.instance.stopSound()
    }
    
    func snooze() {
        if let alarm = activeAlarm {
            alarm.setSnoozeAlarm()
        }
        activeAlarm = nil
        alarmSoundCount = 0
        SoundManager.instance.stopSound()
    }
    
    
}
