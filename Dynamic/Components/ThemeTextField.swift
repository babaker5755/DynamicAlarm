//
//  ThemeTextField.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/6/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material

class ThemeTextField: UIView {
    
    let textField = TextField()
    let placeholderLabel = SubtitleLabel()
    init(_ placeholder: String? = nil) {
        super.init(frame: .zero)
        
        textField.textColor = .blackText
        textField.tintColor = .blackText
        textField.isPlaceholderAnimated = false
        
        textField.placeholderActiveColor = .blackText
        textField.placeholderNormalColor = .blackText
        
        textField.dividerActiveColor = .theme1
        textField.dividerNormalColor = .theme2
        self.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        placeholderLabel.text = placeholder
        placeholderLabel.textAlignment = .left
        self.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.bottom.equalTo(textField.snp.top)
            make.left.equalToSuperview()//.offset(8)
            make.right.equalToSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
