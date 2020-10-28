//
//  Track.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/17/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Mixpanel

class T {
    
    static func track(_ message: String, _ additionalInfo: [String:String]? = nil) {
        print(message, additionalInfo ?? [:])
        Mixpanel.mainInstance().track(event: message, properties: additionalInfo)
    }
    
}
