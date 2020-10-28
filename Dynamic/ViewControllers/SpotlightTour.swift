//
//  SpotlightTour.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/17/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material
import AwesomeSpotlightView


class SpotlightTour: HalfScreenModalViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        T.track("Spotlight Screen Opened")

        let titleLabel = TitleLabel("Thanks for joining Dynamic Alarm!")
        
        self.mainView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.width.equalToSuperview().offset(-64)
        }
        
        let buttonWidth = (Screen.width / 2) - 64
        
        let primaryButton = PrimaryButton("TAKE TOUR")
        primaryButton.addTarget(self, action: #selector(pressedStartTour), for: .touchUpInside)
        self.mainView.addSubview(primaryButton)
        primaryButton.makeConstraints(height: 55) { make in
            make.bottom.equalToSuperview().offset(-42)
            make.width.equalTo(buttonWidth)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(55)
        }
        
        let alternativeButton = AlternativeButton("NO THANKS")
        alternativeButton.addTarget(self, action: #selector(pressedNoTour), for: .touchUpInside)
        self.mainView.addSubview(alternativeButton)
        alternativeButton.makeConstraints(height: 55) { make in
            make.bottom.equalToSuperview().offset(-42)
            make.width.equalTo(buttonWidth)
            make.left.equalToSuperview().offset(24)
            make.height.equalTo(55)
        }
        
        
        let subtitleLabel = SubtitleLabel("Making a Dynamic Alarm is quick and easy, just answer a few question and we will handle the rest! \n\n Would you like to get started by taking a quick tour?")
        subtitleLabel.textColor = UIColor.blackText.lighter()
        subtitleLabel.fontSize = 19
        self.mainView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-64)
            make.bottom.equalTo(primaryButton.snp.top).offset(16)
        }
    }
    
    @objc func pressedStartTour() {
        T.track("Pressed Take Tour")
        guard let nav = self.presentingViewController as? AlarmNavigationController else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.dismiss(animated: true, completion: {
            nav.startSpotlightTour()
        })
    }
    
    @objc func pressedNoTour() {
        T.track("Pressed No Tour")
        self.dismiss(animated: true, completion: nil)
        LocalStorage.didTakeTour = true
    }
    
}

extension AlarmNavigationController : AwesomeSpotlightViewDelegate {
    
    func startSpotlightTour() {
        let spotlight0 = AwesomeSpotlight(withRect: CGRect(x: Screen.width - 132, y: Screen.height - 132, width: 132, height: 132), shape: .roundRectangle, text: "Lets create your first alarm! Press the add button in the bottom right to get started.")
        let spotlight1 = AwesomeSpotlight(withRect: CGRect(x: 12, y: Screen.height * 0.25, width: Screen.width - 30, height: Screen.height * 0.7), shape: .roundRectangle, text: "Select the time you need to arrive at your destination, and how long it takes to get ready.")
        let spotlight2 = AwesomeSpotlight(withRect: CGRect(x: 12, y: Screen.height * 0.25, width: Screen.width - 30, height: Screen.height * 0.7), shape: .roundRectangle, text: "Here is where you can add trips to your alarm. We will keep track of the estimated travel time and adjust your alarm if necessary!")
        let spotlight3 = AwesomeSpotlight(withRect: CGRect(x: 12, y: Screen.height * 0.25, width: Screen.width - 30, height: Screen.height * 0.7), shape: .roundRectangle, text: "You can edit alarm and trip details, add additional trips, configure alarm settings, and preview the alarm!")
        let spotlight4 = AwesomeSpotlight(withRect: CGRect(x: 0, y: Screen.height / 2, width: 0, height: 0), shape: .roundRectangle, text: "Congrats on creating your first Dynamic Alarm! \n The possibilites are endless and you can sleep easy knowing we will get you up on time!")
    
        spotlightView = AwesomeSpotlightView(frame: view.frame, spotlight: [spotlight0, spotlight1, spotlight2, spotlight3, spotlight4])
        spotlightView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        spotlightView.cutoutRadius = 8
        spotlightView.delegate = self
        view.addSubview(spotlightView)
        spotlightView.start()
    }
    
    func spotlightView(_ spotlightView: AwesomeSpotlightView, didNavigateToIndex index: Int) {
        switch index {
        case 1:
            if let vc = self.viewControllers.first(where: {$0 is AlarmTableViewController}) as? AlarmTableViewController {
                vc.didTouchAddButton()
            }
        case 2:
            if let vc = self.viewControllers.first(where: {$0 is CreateAlarmViewController}) as? CreateAlarmViewController {
                vc.didPressSaveAlarm(name: nil)
            }
        case 3:
            if let vc = self.viewControllers.first(where: {$0 is CreateTripViewController}) as? CreateTripViewController {
                vc.delegate?.tripCreated(alarm: vc.alarm, trip: nil)
            }
        case 4:
            self.popToRootViewController(animated: true)
            T.track(LocalStorage.didTakeTour ? "Completed Tour" : "Completed First Tour")
            LocalStorage.didTakeTour = true
            
        default:
            break
        }
    }
}
