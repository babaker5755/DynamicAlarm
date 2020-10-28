//
//  AlternativeButton.swift
//  Dynamic
//
//  Created by Brandon Baker on 4/29/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material
import SnapKit

class AlternativeButton: FlatButton {

    init(_ title: String? = nil) {
        super.init(frame: .zero)
        self.title = title?.uppercased()
        self.titleLabel?.font = .systemFont(ofSize: 21)
        self.titleColor = .blackText
        self.backgroundColor = .clear
    }
    
    func makeConstraints(height: CGFloat, _ closure: (ConstraintMaker) -> Void) {
        self.snp.makeConstraints(closure)
        self.layer.cornerRadius = height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
