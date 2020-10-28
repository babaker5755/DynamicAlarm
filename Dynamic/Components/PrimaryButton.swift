//
//  PrimaryButton.swift
//  Dynamic
//
//  Created by Brandon Baker on 4/29/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material
import SnapKit

class PrimaryButton: FlatButton {

    init(_ title: String? = nil) {
        super.init(frame: .zero)
        self.title = title?.uppercased()
        self.titleLabel?.font = .boldSystemFont(ofSize: 21)
        self.titleColor = .white
        self.backgroundColor = .theme4
    }
    
    func makeConstraints(height: CGFloat, _ closure: (ConstraintMaker) -> Void) {
        self.snp.makeConstraints(closure)
        setShadow(height)
    }
    
    func setShadow(_ height: CGFloat) {
        self.layer.cornerRadius = height / 2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.4
        self.layer.shadowColor = Color.black.lighter()?.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
