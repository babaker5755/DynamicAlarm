//
//  AlarmDetailTableViewCell.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/2/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material

class AlarmDetailTableViewCell: UITableViewCell {

    let rowHeight : CGFloat = 50
    let leftOffset = 48
    let mainView = UIView()
    
    var wakeUpTime : String!
    var nextNotificationText : String!
    var timer : Timer!
    
    var alarm : Alarm? {
        didSet {
            setupViews()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fadeEstimatedAlarm), userInfo: nil, repeats: true)
    }
    
    func setupViews() {
        self.subviews.forEach { $0.removeFromSuperview() }
        self.mainView.subviews.forEach { $0.removeFromSuperview() }
        
        guard let alarm = alarm else { return }
        
        self.wakeUpTime = alarm.wakeUpTime.getString(time: true)
        self.nextNotificationText = alarm.getNextNotificationText()
        
        let info : [(String,String)] = [
            ("Estimated Alarm", wakeUpTime),
            ("Arrival Time", alarm.arrivalTime.getString(time: true)),
            ("Time to Get Ready", alarm.readyTime.getString(0))
        ]
        
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
        
        for (i, infoItem) in info.enumerated() {
            
            let centerY = (rowHeight / 2) + (CGFloat(i) * rowHeight) + 5
            
            let detailLabel = SubtitleLabel()
            detailLabel.tag = i
            detailLabel.text = infoItem.1
            detailLabel.textColor = .blackText
            detailLabel.font = .boldSystemFont(ofSize: 20)
            mainView.addSubview(detailLabel)
            detailLabel.snp.makeConstraints { make in
                make.centerY.equalTo(centerY)
                make.right.equalToSuperview().offset(-20)
            }
            
            detailLabel.isHidden = detailLabel.text == "unknown"
            
            let titleLabel = SubtitleLabel()
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            titleLabel.text = infoItem.0
            titleLabel.textColor = .lightGray
            mainView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.bottom.equalTo(detailLabel)
                make.left.equalToSuperview().offset(leftOffset)
            }
            
            
            let bottom = rowHeight * CGFloat(i)
            if i == info.count || i == 0 { continue }
            let divider = UIView()
            divider.backgroundColor = UIColor.theme4.withAlphaComponent(0.4)
            mainView.addSubview(divider)
            divider.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(1)
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(bottom)
            }
        }
        
    }
    
    @objc func fadeEstimatedAlarm() {

        guard let estimatedTimeLabel = mainView.subviews.first(where: { $0.tag == 0 }) as? UILabel else {
                return
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            estimatedTimeLabel.alpha = 0.0
        }) { _ in
            estimatedTimeLabel.text = estimatedTimeLabel.text == self.wakeUpTime ? self.nextNotificationText : self.wakeUpTime
            UIView.animate(withDuration: 0.4, animations: {
                estimatedTimeLabel.alpha = 1.0
            })
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
