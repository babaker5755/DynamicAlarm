//
//  TripDetailTableViewCell.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/7/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material
import AwesomeEnum

class TripDetailTableViewCell: UITableViewCell {
    
    let rowHeight : CGFloat = 50
    let titleLabel = SubtitleLabel()
    let detailLabel = SubtitleLabel()
    
    let leftOffset = 48
    var info : [(String, String)]!
    
    var alarm : Alarm? {
        didSet {
            setupViews()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        hero.isEnabled = true
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    func setupViews() {
        self.subviews.forEach { $0.removeFromSuperview() }
        
        guard let alarm = alarm, let trips = alarm.tripObjects, let firstTrip = alarm.tripObjects?.first else { return }
        
        let destinationText = trips.count > 1 ? "Destination 1" : "Destination"
        info = [
            ("Starting Location", firstTrip.startAddress.name),
            (destinationText, firstTrip.endAddress.name)
        ]
        
        for (i, trip) in trips.enumerated() {
            if i == 0 { continue }
            info.append(("Destination \(i + 1)", trip.endAddress.name))
        }
        
        let travelTimeText = firstTrip.transportType == .automobile ? "Drive Time" : "Walk Time"
        info.append((travelTimeText, alarm.travelTime.getString(0)))
        
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
            make.bottom.equalToSuperview().offset(-8)
        }
        
        for (i, infoItem) in info.enumerated() {
            
            let centerY = ( rowHeight / 2) + (CGFloat(i) * rowHeight) + 5
            let titleLabel = SubtitleLabel()
            titleLabel.numberOfLines = 1
            titleLabel.textAlignment = .left
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            titleLabel.text = infoItem.0
            titleLabel.textColor = .lightGray
            mainView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.height.equalTo(40)
                make.centerY.equalTo(centerY)
                make.left.equalToSuperview().offset(leftOffset)
            }
            
            let detailLabel = SubtitleLabel()
            detailLabel.text = infoItem.1
            detailLabel.numberOfLines = 1
            detailLabel.textAlignment = .right
            detailLabel.baselineAdjustment = .alignCenters
            detailLabel.textColor = .blackText
            detailLabel.clipsToBounds = false
            detailLabel.font = .boldSystemFont(ofSize: 20)
            mainView.addSubview(detailLabel)
            detailLabel.snp.makeConstraints { make in
                make.height.equalTo(40)
                make.centerY.equalTo(titleLabel)
                make.right.equalToSuperview().offset(-24)
                make.left.equalTo(titleLabel.snp.right).offset(8)
            }
            detailLabel.isHidden = detailLabel.text == "unknown"
            
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
        
        let icon = firstTrip.transportType == .automobile ? Awesome.Solid.car : Awesome.Solid.walking
        
        let imgView = UIImageView(image: icon.asImage(size: 24,
                                                      color: .blackText,
                                                      backgroundColor: .clear))
        self.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        draw(.zero)
        
    }

    let startCircleLayer = CAShapeLayer()
    let endCircleLayer = CAShapeLayer()
    let gradientLayer = CAGradientLayer()
    
    override func draw(_ rect: CGRect) {
        
        let circleWidth : CGFloat = 13
        let circleX : CGFloat = CGFloat(leftOffset) / CGFloat(2)
        let circleYOffset : CGFloat = 32
        let circleLineWidth : CGFloat = 4
        
        let startCircle = UIBezierPath(ovalIn: CGRect(x: circleX,
                                                 y: circleYOffset,
                                                 width: circleWidth,
                                                 height: circleWidth))
        startCircleLayer.path = startCircle.cgPath
        startCircleLayer.lineWidth = 4
        startCircleLayer.lineCap = .round
        startCircleLayer.fillColor = UIColor(white: 1, alpha: 0).cgColor
        startCircleLayer.strokeColor = UIColor.theme4.cgColor
        self.layer.addSublayer(startCircleLayer)
        
        let numberOfDestinations = self.info.count - 2
        let endY : CGFloat = CGFloat((numberOfDestinations) * 50) + circleYOffset
        let endCircle = UIBezierPath(ovalIn: CGRect(x: circleX,
                                                 y: endY,
                                                 width: circleWidth,
                                                 height: circleWidth))
        endCircleLayer.path = endCircle.cgPath
        endCircleLayer.lineWidth = circleLineWidth
        endCircleLayer.lineCap = .round
        endCircleLayer.fillColor = UIColor(white: 1, alpha: 0).cgColor
        endCircleLayer.strokeColor = UIColor.theme1.cgColor
        self.layer.addSublayer(endCircleLayer)
        
        
        gradientLayer.frame = CGRect(x: circleX + circleLineWidth, y: circleYOffset + circleWidth, width: circleWidth / 2.8, height: CGFloat(numberOfDestinations * 50) - circleWidth)
        gradientLayer.colors = [UIColor.theme4, UIColor.theme1].map { $0.cgColor }
        self.layer.addSublayer(gradientLayer)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
