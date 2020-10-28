//
//  AlarmDismissalViewController.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/14/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Lottie
import Material

class AlarmDismissalViewController: UIViewController {
    
    var alarm : Alarm?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        T.track("Alarm Dismissal View Opened")
        
        let titleLabel = TitleLabel(alarm?.name ?? "Alarm")
        titleLabel.numberOfLines = 1
        titleLabel.font = .boldSystemFont(ofSize: 45)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        self.view.addSubview(titleLabel)
        let titleOffset = Screen.height < 800 ? 24 : 72
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(titleOffset)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-100)
        }
        
        let animationView = AnimationView(name: "alarm", bundle: Bundle.main)
        animationView.backgroundColor = UIColor.theme2.withAlphaComponent(0.4)
        animationView.layer.cornerRadius = 24
        animationView.layer.masksToBounds = true
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.5
        animationView.isUserInteractionEnabled = false
        animationView.play()
        self.view.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-128)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(Screen.width * 0.75)
        }

        var message = "You need to get to your destination!"
        if let alarm = alarm {
            let calendar = Calendar.current
            let wakeupComponents = calendar.dateComponents([.hour, .minute], from: alarm.wakeUpTime)
            let arrivalComponents = calendar.dateComponents([.hour, .minute], from: alarm.arrivalTime)
            let timeToDestination = calendar.dateComponents([.minute], from: wakeupComponents, to: arrivalComponents).minute!
            message = "You need to get to your destination in \(timeToDestination) minutes!"
        }
        
        let messageLabel = SubtitleLabel(message)
        messageLabel.font = .systemFont(ofSize: 21)
        messageLabel.adjustsFontSizeToFitWidth = true
        self.view.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
        }
        
        let dismissButton = PrimaryButton("Dismiss")
        dismissButton.addTarget(self, action: #selector(pressedDismiss), for: .touchUpInside)
        self.view.addSubview(dismissButton)
        dismissButton.makeConstraints(height: 55) { make in
            make.bottom.equalToSuperview().offset(-150)
            make.height.equalTo(55)
            make.width.equalToSuperview().offset(-64)
            make.centerX.equalToSuperview()
        }
        
        if alarm?.snooze == .enabled {
            let snoozeButton = AlternativeButton("Snooze")
            snoozeButton.addTarget(self, action: #selector(pressedSnooze), for: .touchUpInside)
            self.view.addSubview(snoozeButton)
            snoozeButton.makeConstraints(height: 55) { make in
                make.top.equalTo(dismissButton.snp.bottom).offset(16)
                make.height.equalTo(55)
                make.width.equalToSuperview().offset(-64)
                make.centerX.equalToSuperview()
            }
        }
    }
    
    @objc func pressedDismiss() {
        AlarmHandler.instance.resetAlarm()
        guard let nav = self.navigationController as? AlarmNavigationController else { return }
        nav.popToRootViewController(animated: true)
        
        if let alarm = alarm, let trip = alarm.tripObjects?.first {
            nav.showAlert(title: "Open Maps", message: "Would you like to open the route in the Maps app?", buttonTitle: "Open", completion: {
                T.track("Opened Apple Maps")
                nav.openMap(for: trip)
            })
        }
    }
    
    @objc func pressedSnooze() {
        AlarmHandler.instance.snooze()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
