//
//  AddAStopTableViewCell.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/7/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material

class AddAStopTableViewCell: UITableViewCell {

    var alarm : Alarm!
    var delegate: TripDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        let addButton = FlatButton()
        addButton.addTarget(self, action: #selector(addTrip), for: .touchUpInside)
        addButton.backgroundColor = .themeWhite
        addButton.layer.cornerRadius = 8
        addButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addButton.layer.shadowRadius = 4
        addButton.layer.shadowOpacity = 0.4
        addButton.layer.shadowColor = Color.black.lighter()?.cgColor
        addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.width.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(8)
            make.height.equalToSuperview().offset(-16)
        }
        
        let detailLabel = SubtitleLabel()
        detailLabel.text = "+  Add a trip"
        detailLabel.textAlignment = .center
        detailLabel.textColor = .blackText
        detailLabel.font = .systemFont(ofSize: 20)
        addButton.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
    }
    
    @objc func addTrip() {
        delegate?.addTrip()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
