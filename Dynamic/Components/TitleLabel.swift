//
//  TitleLabel.swift
//  Dynamic
//
//  Created by Brandon Baker on 4/30/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material

class TitleLabel: UILabel {
    
    func setupLabel(_ text: String? = nil) {
        self.text = text
        self.font = .boldSystemFont(ofSize: 35)
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.textColor = .blackText
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
