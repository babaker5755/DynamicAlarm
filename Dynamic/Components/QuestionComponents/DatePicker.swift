//
//  DatePicker.swift
//  Dynamic
//
//  Created by Brandon Baker on 4/30/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit

class DatePicker: UIDatePicker {

    init() {
        super.init(frame: .zero)
        self.datePickerMode = .time
        self.setValue(UIColor.blackText, forKeyPath: "textColor")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
