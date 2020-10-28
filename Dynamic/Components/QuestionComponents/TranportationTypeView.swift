//
//  TranportationMethodCollectionView.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/2/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import AwesomeEnum
import Material


protocol TransportTypeDelegate {
    func didSetTransportType()
}

class TranportButton : FlatButton {
    
    let imgView = UIImageView()
    let label = UILabel()
    
    var transportType : TransportType = .automobile
    let buttonHeight : CGFloat = 100
    
    init(text: String, transportType: TransportType) {
        super.init(frame: .zero)
        self.transportType = transportType
        
        let icon = transportType == .automobile ? Awesome.Solid.car : Awesome.Solid.walking
        let image = icon.asImage(size: 40,
                                            color: .primary,
                                            backgroundColor: .clear)
        
        imgView.image = image
        self.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-8)
        }
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 16)
        label.text = text
        self.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(imgView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.theme1.cgColor
        self.layer.cornerRadius = buttonHeight / 2
        self.layer.masksToBounds = true
    }
    
    func setSelected() {
        self.backgroundColor = .theme1
        self.label.textColor = .white
        let icon = transportType == .automobile ? Awesome.Solid.car : Awesome.Solid.walking
        let image = icon.asImage(size: 40,
                                 color: .white ,
                                 backgroundColor: .clear)
        imgView.image = image
        
    }
    
    func setUnselected() {
        self.backgroundColor = .clear
        self.label.textColor = .theme1
        let icon = transportType == .automobile ? Awesome.Solid.car : Awesome.Solid.walking
        let image = icon.asImage(size: 40,
                                 color: .theme1 ,
                                 backgroundColor: .clear)
        imgView.image = image
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TranportationTypeView: UIView {
    
    var transportTypes : [TransportType] = [.automobile, .walking]
    var selectedType : TransportType = .automobile {
        didSet {
            setSelected()
        }
    }
    
    var delegate : TransportTypeDelegate?
    
    var buttonHeight : CGFloat! = 100
    let carButton : TranportButton! = TranportButton(text: "Car", transportType: .automobile)
    let walkButton : TranportButton! = TranportButton(text: "Walk", transportType: .walking)
    
    init() {
        self.buttonHeight = carButton.buttonHeight
        super.init(frame: .zero)
        
        carButton.addTarget(self, action: #selector(carSelected), for: .touchUpInside)
        self.addSubview(carButton)
        carButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(buttonHeight)
            make.centerX.equalToSuperview().offset(-buttonHeight * 0.75)
        }
        
        walkButton.addTarget(self, action: #selector(walkSelected), for: .touchUpInside)
        self.addSubview(walkButton)
        walkButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(buttonHeight)
            make.centerX.equalToSuperview().offset(buttonHeight * 0.75)
        }
        setSelected()
    }
    
    @objc func carSelected() {
        selectedType = .automobile
    }
    
    @objc func walkSelected() {
        selectedType = .walking
    }
    
    func setSelected() {
        delegate?.didSetTransportType()
        if selectedType == .automobile {
            carButton.setSelected()
            walkButton.setUnselected()
        } else if selectedType == .walking {
            walkButton.setSelected()
            carButton.setUnselected()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
