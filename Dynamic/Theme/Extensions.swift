//
//  Extensions.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/11/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit

extension Date {
    
    func getSecondsUntil() -> Int? {
        return Calendar.current.dateComponents([.second], from: Date(), to: self).second
    }
}

extension Int {
    
    static func seconds(minutes: Int) -> Int {
        return minutes * 60
    }
    static func seconds(hours: Int) -> Int {
        return hours * 3600
    }
    
    
}
