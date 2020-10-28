//
//  CircleButton.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/8/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material

class CircleButton: RaisedButton {
    
    init(image: UIImage, color: UIColor, size: CGFloat) {
        super.init(image: image)
        self.backgroundColor = color
        self.titleColor = .themeWhite
        self.isHidden = false
        
        self.layer.cornerRadius = size / 2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.4
        self.layer.shadowColor = Color.black.lighter()?.cgColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
