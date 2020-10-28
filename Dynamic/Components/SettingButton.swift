//
//  SettingButton.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/8/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material
import AwesomeEnum

enum SettingType : String {
    case sound = "Sound"
    case volume = "Volume"
    case snooze = "Snooze"
    case repeating = "Repeat"
}

class SettingButton: FlatButton {
    
    var type : SettingType
    
    let valueLabel = SubtitleLabel()
    
    init(type: SettingType, value: String) {
        self.type = type
        super.init(frame: .zero)
        setupViews()
        
        valueLabel.text = value
    }
    
    init(type: SettingType, value: NSMutableAttributedString) {
        self.type = type
        super.init(frame: .zero)
        setupViews()
        
        valueLabel.attributedText = value
    }
    
    func setupViews() {
        
        self.backgroundColor = getColor().withAlphaComponent(0.8)
        self.layer.cornerRadius = 8
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.4
        self.layer.shadowColor = Color.black.lighter()?.cgColor
        
        let imageView = UIImageView(image: getIcon())
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }
        
        let detailLabel = SubtitleLabel()
        detailLabel.text = type.rawValue
        detailLabel.textAlignment = .center
        detailLabel.textColor = .themeWhite//.blackText
        detailLabel.font = .systemFont(ofSize: 20)
        self.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        valueLabel.textAlignment = .center
        valueLabel.textColor = UIColor.themeWhite.withAlphaComponent(0.7) //.blackText
        valueLabel.font = .systemFont(ofSize: 18, weight: .light)
        self.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-4)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-8)
        }
        
    }
    
    func getColor() -> UIColor {
        switch type {
        case .sound:
            return .theme2
        case .volume:
            return .theme1
        case .repeating:
            return .theme5
        case .snooze:
            return .theme4
        }
    }
    
    func getIcon() -> UIImage {
        var image = UIImage()
        
        let awesome = Awesome.Solid.self
        switch type {
        case .sound:
            image = awesome.fileAudio.asImage(size: 50,
                                             color: .themeWhite,
                                             backgroundColor: .clear)
        case .volume:
            image = awesome.volumeUp.asImage(size: 50,
                                             color: .themeWhite,
                                             backgroundColor: .clear)
        case .snooze:
            image = awesome.bed.asImage(size: 50,
                                             color: .themeWhite,
                                             backgroundColor: .clear)
        case .repeating:
            image = awesome.calendarAlt.asImage(size: 50,
                                             color: .themeWhite,
                                             backgroundColor: .clear)
        }
        return image
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
