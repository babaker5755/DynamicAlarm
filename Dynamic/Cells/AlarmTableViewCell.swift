//
//  AlarmTableViewCell.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/1/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material

class AlarmTableViewCell: UITableViewCell {
    
    var alarm : Alarm! {
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
        self.subviews.forEach { $0.removeFromSuperview() }
        let mainView = UIView()
        mainView.backgroundColor = .themeWhite
        mainView.layer.cornerRadius = 8
        mainView.layer.shadowOffset = CGSize(width: 0, height: 2)
        mainView.layer.shadowRadius = 4
        mainView.layer.shadowOpacity = 0.4
        mainView.layer.shadowColor = Color.black.lighter()?.cgColor
        addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.height.equalToSuperview().offset(-16)
        }
        
        let topView = UIView()
        mainView.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.75)
        }
        
        let timeLabel = TitleLabel(alarm.wakeUpTime.getString(time: true))
        timeLabel.textColor = .blackText
        topView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
        }
        
        
        let enableSwitch = UISwitch()
        enableSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .touchUpInside)
        enableSwitch.onTintColor = .theme4
        enableSwitch.isOn = alarm.enabled
        topView.addSubview(enableSwitch)
        enableSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.width.equalTo(70)
            make.height.equalTo(35)
            make.centerY.equalToSuperview()
        }
        
        let bottomView = UIView()
        bottomView.layer.cornerRadius = 8
        bottomView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        bottomView.backgroundColor = .theme1
        mainView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        let nameLabel = UILabel()
        nameLabel.text = alarm.name
        nameLabel.textColor = .themeWhite
        nameLabel.font = .systemFont(ofSize: 20, weight: .light)
        bottomView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.centerY.equalToSuperview()
        }
        
        let repeatLabel = UILabel()
        repeatLabel.attributedText = alarm.getDayAbbreviationString()
        bottomView.addSubview(repeatLabel)
        repeatLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-32)
            make.centerY.equalToSuperview()
        }
        
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        alarm.enabled = sender.isOn
        alarm.saveAlarm()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
