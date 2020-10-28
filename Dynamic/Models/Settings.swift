//
//  Settings.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/10/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import AVFoundation

enum Snooze : String, CaseIterable, Codable {
    case enabled = "Enabled"
    case disabled = "Disabled"
}

enum RepeatDay : String, CaseIterable, Codable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    
    func getAbbreviation() -> String{
        switch self {
        case .sunday : return "S"
        case .monday : return "M"
        case .tuesday : return "T"
        case .wednesday : return "W"
        case .thursday : return "R"
        case .friday : return "F"
        case .saturday : return "S"
        }
    }
    func getInt() -> Int {
        switch self {
        case .sunday : return 1
        case .monday : return 2
        case .tuesday : return 3
        case .wednesday : return 4
        case .thursday : return 5
        case .friday : return 6
        case .saturday : return 7
        }
    }
    
}

enum Sound : String, CaseIterable, Codable {
    case alarm_clock_classic = "alarm_clock_classic.mp3"
    case alarm_clock_tropical = "alarm_sound_tropical.mp3"
    case alarm_clock = "alarm_clock.mp3"
    case alarm_dubstep = "alarm_dubstep.mp3"
    case alarm_tone = "alarm_tone.mp3"
    case siren = "siren.mp3"
    case classic = "classic.mp3"
    case analog = "analog.wav"
    case schoolBell = "schoolBell.wav"
    case oldDoorBell = "oldDoorBell.wav"
    case barge = "barge.wav"
    case railroard = "railroad.wav"
    case loudBuzzer = "loudBuzzer.wav"
    
    func name() -> String {
        switch self {
        case .siren: return "Siren"
        case .classic: return "Classic"
        case .analog: return "Analog"
        case .schoolBell: return "School Bell"
        case .oldDoorBell: return "Old Door Bell"
        case .barge: return "Barge"
        case .railroard: return "Railroad"
        case .loudBuzzer: return "Loud Buzzer"
        case .alarm_dubstep: return "Dubstep"
        case .alarm_tone: return "Alarm Tone"
        case .alarm_clock_classic: return "Alarm Clock Classic"
        case .alarm_clock_tropical: return "Tropical"
        case .alarm_clock: return "Rooster Alarm"
        }
    }
    
    func duration() -> Double {
        let asset = AVURLAsset(url: URL(fileURLWithPath: self.rawValue))
        let duration = Double(CMTimeGetSeconds(asset.duration))
        return duration < 10 ? 10 : duration
    }
}

enum Volume : String, Codable, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    case ascending = "Ascending"
    case descending = "Descending"
    
    func getValue() -> Float {
        switch self {
        case .high: return 1.0
        case .medium: return 0.7
        case .low: return 0.4
        case .ascending: return 0.2
        case .descending: return 1.0
        }
    }
}
