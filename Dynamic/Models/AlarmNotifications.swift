//
//  AlarmNotifications.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/14/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit

extension Alarm {
    
    func saveAlarm() {
        if let alarmIndex = LocalStorage.savedAlarms.firstIndex(where: {$0.id == self.id}) {
            // If it exists, update it
            LocalStorage.savedAlarms[alarmIndex] = self
            ScheduledNotification.updateAlarmsInDatabase()
        } else {
            // else create a new one
            LocalStorage.savedAlarms.append(self)
            ScheduledNotification.updateAlarmsInDatabase()
        }
        
    }
    
    // Will set notifications for alarms
    // that will sound either today or tomorrow
    func handleAlarmWithCloseExpiration(today: Bool) ->  Int? {
        let calendar = Calendar.current
        
        let wakeupComponents = calendar.dateComponents([.hour, .minute], from: self.wakeUpTime)
        var todayComponents : DateComponents
        
        if today {
            todayComponents = calendar.dateComponents([.weekday, .year, .month, .day], from: Date.today)
        } else {
            todayComponents = calendar.dateComponents([.weekday, .year, .month, .day], from: Date.tomorrow)
        }
        
        // build date using
        // today date and alarm time
        var alarmComponents = DateComponents()
        alarmComponents.year = todayComponents.year!
        alarmComponents.month = todayComponents.month!
        alarmComponents.day = todayComponents.day!
        alarmComponents.weekday = todayComponents.weekday!
        alarmComponents.hour = wakeupComponents.hour!
        alarmComponents.minute = wakeupComponents.minute!
        guard var alarmDate = calendar.date(from: alarmComponents) else { return nil }
        
        var secondsUntilAlarm = alarmDate.getSecondsUntil()
        
        // if the alarm has already passed
        // check tomorrow
        if secondsUntilAlarm ?? 1 < 0 && !shouldSoundWhenPassed {
            let tomorrowComponents = calendar.dateComponents([.weekday, .year, .month, .day], from: Date.tomorrow)
            alarmComponents = DateComponents()
            alarmComponents.year = tomorrowComponents.year!
            alarmComponents.month = tomorrowComponents.month!
            alarmComponents.day = tomorrowComponents.day!
            alarmComponents.weekday = tomorrowComponents.weekday!
            alarmComponents.hour = wakeupComponents.hour!
            alarmComponents.minute = wakeupComponents.minute!
            guard let nextAlarmDate = calendar.date(from: alarmComponents) else { return nil }
            alarmDate = nextAlarmDate
            secondsUntilAlarm = alarmDate.getSecondsUntil()
        }
        
        shouldSoundWhenPassed = true
        return secondsUntilAlarm
    }
    
    func getNextNotification() -> Int? {
        
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.weekday, .year, .month, .day], from: Date.today)
        let todayWeekday = todayComponents.weekday!
        
        let tomorrowComponents = calendar.dateComponents([.weekday, .year, .month, .day], from: Date.tomorrow)
        let tomorrowWeekday = tomorrowComponents.weekday!
        
        if enabled && repeating.isEmpty {
            return handleAlarmWithCloseExpiration(today: true)
        }
        if self.repeating.contains(where: { $0.getInt() == todayWeekday }) {
            return handleAlarmWithCloseExpiration(today: true)
        }
        if self.repeating.contains(where: { $0.getInt() == tomorrowWeekday }) {
            return handleAlarmWithCloseExpiration(today: false)
        }
        
        return nil
    }
    
    func getNextNotificationText() -> String? {
        guard let nextNotification = self.getNextNotification() else {
            if self.repeating.isEmpty || !self.enabled {
                return "Not Set"
            }
            let todayWeekday = Calendar.current.dateComponents([.weekday, .year, .month, .day], from: Date.today).weekday!
            return self.repeating.sorted(by: { $0.getInt() < $1.getInt() }).first(where: { $0.getInt() > todayWeekday })?.rawValue
        }
        let minutes = nextNotification / 60
        let hours = minutes / 60
        if minutes < 180 {
            return "~\(minutes) minutes"
        } else {
            return "~\(hours) hours"
        }
    }
    
}
