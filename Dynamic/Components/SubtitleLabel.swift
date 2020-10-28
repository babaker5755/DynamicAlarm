//
//  SubtitleLabel.swift
//  Dynamic
//
//  Created by Brandon Baker on 4/30/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit

class SubtitleLabel: UILabel {
    
    func setupLabel(_ text: String? = nil) {
        self.text = text
        self.font = .systemFont(ofSize: 18)
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.adjustsFontSizeToFitWidth = true
        self.textColor = UIColor.blackText.lighter(by: 45)
        self.textAlignment = .center
    }

    init(_ text: String) {
        super.init(frame: .zero)
        setupLabel(text)
    }
    
    init() {
        super.init(frame: .zero)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        setupLabel()
    }
}
