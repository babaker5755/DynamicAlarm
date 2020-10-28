//
//  NumberPicker.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/1/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import DropDown
import Material

class NumberPicker: UIView {
    
    let values : [Double] = [0,5,10,15,20,25,30]
    var value : Double = 5.0
    let segmentController : UISegmentedControl!
    var dropDown = DropDown()
    
    init() {
        segmentController = UISegmentedControl(items: values.map {
            let string = $0.getString(0)
            return string == "30" ? string + "+" : string
        })
        
        super.init(frame: .zero)
        
        segmentController.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.blackText,
        ], for: .normal)
        segmentController.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white,
        ], for: .selected)
        segmentController.selectedSegmentTintColor = UIColor.primary
        segmentController.selectedSegmentIndex = 1
        segmentController.selectedSegmentTintColor = .theme1
        segmentController.backgroundColor = .theme2
        segmentController.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        self.addSubview(segmentController)
        segmentController.snp.makeConstraints{ make in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        let anchorView = UIView(frame: CGRect(x: segmentController.frame.maxX, y: segmentController.frame.maxY, width: 80, height: 80))
        self.addSubview(anchorView)
        dropDown.anchorView = anchorView
        dropDown.width = 80
        dropDown.frame.origin.x = Screen.width - 36
        dropDown.dataSource = ["30", "45", "60", "75", "90", "105", "120"]
        dropDown.selectionAction = { (index, item) in
            guard let double = Double("\(item)") else { return }
            self.value = double
            self.segmentController.removeSegment(at: 6, animated: true)
            self.segmentController.insertSegment(withTitle: item, at: 6, animated: true)
            self.segmentController.selectedSegmentIndex = 6
        }
    }
    
    @objc func valueChanged(_ sender: UISegmentedControl) {
        guard sender.selectedSegmentIndex != 6 else {
            dropDown.show()
            return
        }
        self.value = values[sender.selectedSegmentIndex]
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
