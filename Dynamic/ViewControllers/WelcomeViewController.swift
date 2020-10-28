//
//  WelcomeViewController.swift
//  Dynamic
//
//  Created by Brandon Baker on 4/30/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Lottie
import Material
import Hero

class WelcomeViewController: UIViewController {
    
    let animationView = AnimationView(name: MountainAnimation.get().rawValue, bundle: Bundle.main)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isHeroEnabled = true
        view.backgroundColor = .theme3
        
        // mountain animation
        animationView.hero.id = "animationView"
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        animationView.isUserInteractionEnabled = false
        animationView.play()
        view.addSubview(animationView)
        let height = 2436 / 2.6
        let width = 1427 / 2.6
        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(height)
            make.width.equalTo(width)
        }
        
        let offset : CGFloat = 220
        let transluscentView = UIView()
        transluscentView.hero.id = "transluscentView"
        transluscentView.backgroundColor = UIColor.themeWhite.withAlphaComponent(0.6)
        transluscentView.layer.cornerRadius = 24
        transluscentView.layer.masksToBounds = true
        transluscentView.frame = CGRect(x: 32, y: offset, width: Screen.width - 64, height: 260)
        self.view.addSubview(transluscentView)
        
        // Labels
        let titleLabel = TitleLabel("Welcome to")
        //        titleLabel.font = .monoFur
        titleLabel.frame = CGRect(x: 32, y: offset, width: Screen.width - 64, height: 40)
        view.addSubview(titleLabel)
        
        let titleLabel1 = TitleLabel("Dynamic Alarm")
        //        titleLabel1.font = .monoFur
        titleLabel1.frame = CGRect(x: 32, y: offset + 40, width: Screen.width - 64, height: 40)
        view.addSubview(titleLabel1)
        
        let subtitleLabel = SubtitleLabel("Dynamic Alarm is a traffic monitoring smart alarm that decides when you should wake up based on your morning routine and real time traffic updates.")
        subtitleLabel.textColor = UIColor.black.lighter(by: 25)
        subtitleLabel.frame = CGRect(x: 48, y: offset + 90, width: Screen.width - 96, height: 120)
        view.addSubview(subtitleLabel)
        
        // Buttons
        let buttonOffset : CGFloat = Screen.height < 700 ? 100 : 155
        let buttonHeight : CGFloat = 55
        let primaryButton = PrimaryButton("Get Started")
        primaryButton.frame = CGRect(x: 32, y: Screen.height - buttonOffset, width: Screen.width - 64, height: buttonHeight)
        primaryButton.hero.id = "primaryButton"
        primaryButton.layer.zPosition = 2
        primaryButton.addTarget(self, action: #selector(pressedStart), for: .touchUpInside)
        view.addSubview(primaryButton)
        primaryButton.setShadow(buttonHeight)
        
        animationView.alpha = 0.0
        subtitleLabel.alpha = 0.0
        titleLabel.alpha = 0.0
        titleLabel1.alpha = 0.0
        transluscentView.alpha = 0.0
        primaryButton.alpha = 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            // 1
            UIView.animate(withDuration: 0.3, animations: {
                // animated
                self.animationView.alpha = 1.0
            }) { _ in
                // 2
                UIView.animate(withDuration: 1, animations: {
                    // animated
                    titleLabel.alpha = 1.0
                    titleLabel.frame.origin.y += 50
                }) { _ in
                    // 3
                    UIView.animate(withDuration: 1, animations: {
                        // animated
                        titleLabel1.alpha = 1.0
                        titleLabel1.frame.origin.y += 50
                    }) { _ in
                        // 4
                        UIView.animate(withDuration: 1, animations: {
                            // animated
                            subtitleLabel.alpha = 1.0
                            subtitleLabel.frame.origin.y += 50
                        }) { _ in
                            // 5
                            UIView.animate(withDuration: 1, animations: {
                                // animated
                                transluscentView.alpha = 1.0
                            }) { _ in
                                // 6
                                UIView.animate(withDuration: 0.6, animations: {
                                    // animated
                                    primaryButton.alpha = 1.0
                                    primaryButton.frame.origin.y -= 50
                                }) { _ in
                                    
                                }
                            }
                        }
                    }
                }
            }
        })
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animationView.play()
    }
    
    @objc func pressedStart() {
        let tutorialVc = TutorialViewController()
        tutorialVc.animationView.currentProgress = animationView.realtimeAnimationProgress + 0.03
        self.navigationController?.pushViewController(tutorialVc, animated: true)
    }
}

enum MountainAnimation : String{
    case m2208x1242 = "mountains2208x1242"
    case m2436x1427 = "mountains2436x1427"
    case m2688x1512 = "mountains2688x1512"
    
    static func get() -> MountainAnimation {
        if Screen.height > 2687 {
            return .m2688x1512
        } else if Screen.height > 2435 {
            return .m2688x1512
        } else if Screen.height > 2207 {
            return .m2688x1512
        } else {
            return .m2688x1512
        }
    }
}
