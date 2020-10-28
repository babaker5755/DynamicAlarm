//
//  Dialog.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/9/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialDialogs
import Material

extension UIViewController {
    
    
    func showAlert(title: String, message: String, cancelButtonAction: (() -> Void)? = nil, buttonTitle: String = "OK", completion: (() -> Void)?) {
        let alertController = MDCAlertController(title: title, message: message)
        let action = MDCAlertAction(title:buttonTitle) { _ in
            completion?()
        }
        let cancel = MDCAlertAction(title:"Cancel")
        
        alertController.addAction(action)
        alertController.addAction(cancel)
        self.present(alertController, animated:true, completion: nil)
    }
    
    func showAlarmNameDialog(title: String, message: String, completion: ((String?) -> Void)?) {
        
        let alertController = MDCAlertController(title: title, message: "\(message)\n\n\n\n\n")
        let field = TextField()
        
        let action = MDCAlertAction(title:"Save") { _ in
            completion?(field.text)
        }
        alertController.addAction(action)
        
        let cancel = MDCAlertAction(title:"Cancel")
        alertController.addAction(cancel)
        
        var messageLabel : UILabel? = nil
        
        alertController.view.subviews.forEach { view in
            
            if let scrollView = view as? UIScrollView {
                
                scrollView.subviews.forEach {
                    
                    if let label = $0 as? UILabel, label.text?.contains(message) ?? false {
                        messageLabel = label
                    }
                    
                }
                
            }
            
        }
        
        if let messageLabel = messageLabel {
            field.tintColor = .foreground
            field.dividerActiveColor = .foreground
            field.placeholderActiveColor = .foreground
            field.placeholder = "Alarm Name"
            alertController.view.addSubview(field)
            field.snp.makeConstraints { make in
                make.top.equalTo(messageLabel.snp.top).offset(40)
                make.width.equalToSuperview().offset(-48)
                make.height.equalTo(40)
                make.centerX.equalToSuperview()
            }
        }
        self.present(alertController, animated:true, completion: nil)
    }
}
