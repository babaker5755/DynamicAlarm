//
//  SettingsTableViewCell.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/8/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material

protocol SettingsDelegate {
    func didPressSettingButton(_ type: SettingType)
}

class SettingsTableViewCell: UITableViewCell {

    var alarm : Alarm!
    var delegate: SettingsDelegate?
    var types : [SettingType]? {
        didSet {
            setupViews()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    func setupViews() {
        
        guard let types = self.types else { return }
        
        self.subviews.forEach { $0.removeFromSuperview() }
        var leftButton : SettingButton!
        let type = types[0]
        if type == .repeating {
            leftButton =  SettingButton(type: type, value: getAttributedValue(for: type))
        } else {
            leftButton = SettingButton(type: type, value: getValue(for: type))
        }
        leftButton.addTarget(self, action: #selector(didSelectSetting), for: .touchUpInside)
        addSubview(leftButton)
        leftButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.width.equalToSuperview().dividedBy(2).offset(-16)
            make.left.equalToSuperview().offset(8)
            make.height.equalToSuperview().offset(-16)
        }
        
        if types.count == 2 {
            
            var rightButton : SettingButton!
            let type = types[1]
            if type == .repeating {
                rightButton =  SettingButton(type: type, value: getAttributedValue(for: type))
            } else {
                rightButton = SettingButton(type: type, value: getValue(for: type))
            }
            rightButton.addTarget(self, action: #selector(didSelectSetting), for: .touchUpInside)
            addSubview(rightButton)
            rightButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.width.equalToSuperview().dividedBy(2).offset(-16)
                make.right.equalToSuperview().offset(-8)
                make.height.equalToSuperview().offset(-16)
            }
        }
    }
    
    func getValue(for type: SettingType) -> String {
        switch type {
        case .sound: return alarm.sound.name()
        case .volume: return alarm.volume.rawValue
        case .snooze: return alarm.snooze.rawValue
        case .repeating:return String()
        }
    }
    
    func getAttributedValue(for type: SettingType) -> NSMutableAttributedString {
        guard type == .repeating else { return NSMutableAttributedString() }
        return alarm.getDayAbbreviationString()
    }
    
    @objc func didSelectSetting(_ sender: SettingButton) {
        delegate?.didPressSettingButton(sender.type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
