//
//  TutorialViewController.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/15/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material
import Lottie
import Hero
import AwesomeEnum

struct Tutorial {
    var title: String
    var subtitle: String
    var buttonTitle: String
    var animationString: String
    static var currentTutorialIndex = 0
    static let tutorials = [
        Tutorial(title: "Always be on time!",
                 subtitle: "Dynamic Alarm uses real time traffic updates to adjust your alarm while you sleep so that you always arrive at your destination on time!",
                 buttonTitle: "NEXT",
                 animationString: "maps3"),
        Tutorial(title: "Sleep Easy",
                 subtitle: "Get an alarm that worries for you.\nJust tell us your morning routine and where you're going. We will handle the rest!",
                 buttonTitle: "NEXT",
                 animationString: "monkey2"),
        Tutorial(title: "Perfect Alarm",
                 subtitle: "With great alarm sounds, custom volume settings, and extremely reliable notifications you'll never look back!",
                 buttonTitle: "FINISH",
                 animationString: "alarm")
    ]
}

class TutorialViewController: UIViewController {
    
    let animationView = AnimationView(name: MountainAnimation.get().rawValue, bundle: Bundle.main)
    var mapAnimation = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if Tutorial.currentTutorialIndex < 0 {
            Tutorial.currentTutorialIndex = 0
        } else if Tutorial.currentTutorialIndex > Tutorial.tutorials.count - 1 {
            Tutorial.currentTutorialIndex = Tutorial.tutorials.count - 1
        }
        
        let tutorial = Tutorial.tutorials[Tutorial.currentTutorialIndex]
        let isFirstTutorial = Tutorial.currentTutorialIndex == 0
        
        isHeroEnabled = true
        view.backgroundColor = .theme3
        
        // Mountain animation
        animationView.loopMode = .loop
        animationView.isUserInteractionEnabled = false
        animationView.hero.id = isFirstTutorial ? "animationView" : nil
        animationView.animationSpeed = 1
        animationView.play()
        view.addSubview(animationView)
        let height = 2436 / 2.6
        let width = 1427 / 2.6
        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(height)
            make.width.equalTo(width)
        }
        
        let transluscentView = UIView()
        transluscentView.hero.id = isFirstTutorial ? "transluscentView" : nil
        transluscentView.backgroundColor = UIColor.themeWhite.withAlphaComponent(0.90)
        transluscentView.layer.cornerRadius = 24
        transluscentView.layer.masksToBounds = true
        self.view.addSubview(transluscentView)
        transluscentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(125)
            make.bottom.equalToSuperview().offset(-125)
            make.width.equalToSuperview().offset(-64)
            make.centerX.equalToSuperview()
        }
        
        // Labels
        let titleLabel = TitleLabel(tutorial.title)
        titleLabel.adjustsFontSizeToFitWidth = true
        transluscentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        let subtitleLabel = SubtitleLabel(tutorial.subtitle)
        transluscentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.width.equalToSuperview().offset(-24)
            make.centerX.equalToSuperview()
            make.height.equalTo(120)
        }
        
        // Buttons
        let buttonHeight : CGFloat = 55
        let primaryButton = PrimaryButton(tutorial.buttonTitle)
        primaryButton.hero.id = isFirstTutorial ? "primaryButton" : nil
        primaryButton.layer.zPosition = 2
        primaryButton.addTarget(self, action: #selector(pressedNext), for: .touchUpInside)
        transluscentView.addSubview(primaryButton)
        primaryButton.makeConstraints(height: buttonHeight) { make in
            make.bottom.equalToSuperview().offset(-32)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(buttonHeight)
            make.centerX.equalToSuperview()
        }
        
        
        let buttonSize : CGFloat = 60
        let backImage = Awesome.Solid.chevronLeft.asImage(size: buttonSize / 2, color: .themeWhite, backgroundColor: .clear)
        let backButton = CircleButton(image: backImage, color: .theme4, size: buttonSize)
        backButton.hero.id = "backButton"
        backButton.addTarget(self, action: #selector(pressedBack), for: .touchUpInside)
        self.view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.bottom.equalTo(transluscentView.snp.top).offset(-16)
            make.left.equalToSuperview().offset(36)
            make.width.height.equalTo(buttonSize)
        }
        
        // Animation
        mapAnimation = AnimationView(name: tutorial.animationString, bundle: Bundle.main)
        mapAnimation.loopMode = .loop
        mapAnimation.animationSpeed = 1.0
        mapAnimation.isUserInteractionEnabled = false
        mapAnimation.play()
        transluscentView.addSubview(mapAnimation)
        mapAnimation.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom)
            _ = tutorial.animationString == "alarm" ?
                make.bottom.equalTo(primaryButton.snp.top).offset(-50) : make.bottom.equalTo(primaryButton.snp.top).offset(50)
            make.width.equalTo(mapAnimation.snp.height)
            make.centerX.equalToSuperview()
        }
         
    }
    override func viewDidAppear(_ animated: Bool) {
        mapAnimation.play()
        animationView.play()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    @objc func pressedNext() {
        if Tutorial.currentTutorialIndex == Tutorial.tutorials.count - 1 {
            guard let nav = self.navigationController as? AlarmNavigationController else { return }
            
            if Products.store.isPurchased() {
                let alarmTableView = AlarmTableViewController()
                alarmTableView.delegate = nav
                nav.pushViewController(alarmTableView, animated: true)
                nav.viewControllers = [alarmTableView]
            } else {
                let vc = TrialViewController()
                vc.animationView.currentProgress = animationView.realtimeAnimationProgress + 0.03
                nav.heroNavigationAnimationType = .selectBy(presenting: .slide(direction: .left), dismissing: .slide(direction: .right))
                nav.pushViewController(vc, animated: true)
            }
        } else {
            Tutorial.currentTutorialIndex += 1
            let tutorialVc = TutorialViewController()
            tutorialVc.animationView.currentProgress = animationView.realtimeAnimationProgress + 0.03
            self.navigationController?.heroNavigationAnimationType = .selectBy(presenting: .slide(direction: .left), dismissing: .slide(direction: .right))
            self.navigationController?.pushViewController(tutorialVc, animated: true)
        }
    }
    
    @objc func pressedBack() {
        Tutorial.currentTutorialIndex -= 1
        self.navigationController?.popViewController(animated: true)
    }
    
}
