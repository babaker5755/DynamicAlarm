//
//  TrialViewController.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/15/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material
import Hero
import Lottie
import MaterialComponents.MaterialDialogs
import AwesomeEnum

class TrialViewController: UIViewController, PurchaseDelegate {
    
    let animationView = AnimationView(name: MountainAnimation.get().rawValue, bundle: Bundle.main)
    let personAnimation = AnimationView(name: "person", bundle: Bundle.main)
    let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isHeroEnabled = true
        view.backgroundColor = .theme3
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: Screen.width - 64, height: 1000)
        
        T.track("Trial Screen Opened")
        
        // mountain animation
        animationView.loopMode = .loop
        animationView.isUserInteractionEnabled = false
        animationView.hero.id = "animationView"
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
        
        let transluscentView = scrollView
        transluscentView.hero.id = "transluscentView"
        transluscentView.backgroundColor = UIColor.themeWhite.withAlphaComponent(0.80)
        transluscentView.layer.cornerRadius = 24
        transluscentView.layer.masksToBounds = true
        view.addSubview(transluscentView)
        transluscentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(120)
            make.bottom.equalToSuperview().offset(-80)
            make.width.equalToSuperview().offset(-64)
            make.centerX.equalToSuperview()
        }
        
        // Labels
        let titleLabel = TitleLabel("Dynamic Alarm Subscription")
        titleLabel.numberOfLines = 1
        titleLabel.fontSize = 30
        titleLabel.adjustsFontSizeToFitWidth = true
        transluscentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.width.equalToSuperview().offset(-36)
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(40)
        }
        
        let subtitleLabel = SubtitleLabel("Subscribe to Dynamic Alarm today and get a 7-day free trial!\n\n Try out all of our great features with no commitment!")
        subtitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.numberOfLines = 5
        transluscentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.width.equalToSuperview().offset(-24)
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(130)
        }
        
        let trialLabel = SubtitleLabel("After the trial it's only $0.99 / month\nor $9.99 / year.")
        transluscentView.addSubview(trialLabel)
        trialLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom)
            make.width.equalToSuperview().offset(-24)
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(90)
        }

        
        // Buttons
        let buttonHeight : CGFloat = 65
        let monthlySubButton = PrimaryButton()
        let monthlyAttText = NSMutableAttributedString()
        monthlyAttText.customText("Start Free Trial", font: .systemFont(ofSize: 18, weight: .semibold), color: .themeWhite).customText("\nThen, $0.99 / month", font: .systemFont(ofSize: 16, weight: .light), color: .themeWhite)
        monthlySubButton.setAttributedTitle(monthlyAttText, for: .normal)
        monthlySubButton.titleLabel?.numberOfLines = 2
        monthlySubButton.titleLabel?.textAlignment = .center
        monthlySubButton.layer.zPosition = 2
        monthlySubButton.addTarget(self, action: #selector(pressedMonthlyPurchase), for: .touchUpInside)
        transluscentView.addSubview(monthlySubButton)
        monthlySubButton.makeConstraints(height: buttonHeight) { make in
            make.top.equalTo(trialLabel.snp.bottom).offset(300)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(buttonHeight)
            make.centerX.equalToSuperview()
        }
        
        let yearlySubButton = PrimaryButton()
        let yearlyAttText = NSMutableAttributedString()
        yearlyAttText.customText("Start Free Trial", font: .systemFont(ofSize: 18, weight: .semibold), color: .themeWhite).customText("\nThen, $9.99 / year", font: .systemFont(ofSize: 16, weight: .light), color: .themeWhite)
        yearlySubButton.setAttributedTitle(yearlyAttText, for: .normal)
        yearlySubButton.titleLabel?.numberOfLines = 2
        yearlySubButton.titleLabel?.textAlignment = .center
        yearlySubButton.layer.zPosition = 2
        yearlySubButton.addTarget(self, action: #selector(pressedYearlyPurchase), for: .touchUpInside)
        transluscentView.addSubview(yearlySubButton)
        yearlySubButton.makeConstraints(height: buttonHeight) { make in
            make.top.equalTo(monthlySubButton.snp.bottom).offset(16)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(buttonHeight)
            make.centerX.equalToSuperview()
        }
        
        let cancelLabel = SubtitleLabel("Subscriptions billed as one payment each period.\nCancel anytime - no questions asked.")
        cancelLabel.font = .systemFont(ofSize: 14, weight: .medium)
        cancelLabel.textColor = UIColor.blackText.lighter(by: 30)
        transluscentView.addSubview(cancelLabel)
        cancelLabel.snp.makeConstraints { make in
            make.top.equalTo(yearlySubButton.snp.bottom).offset(16)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(50)
        }
        
        let termsButton = AlternativeButton("Terms of Use")
        termsButton.addTarget(self, action: #selector(pressedTerms), for: .touchUpInside)
        transluscentView.addSubview(termsButton)
        termsButton.snp.makeConstraints { make in
            make.top.equalTo(cancelLabel.snp.bottom).offset(16)
            make.width.equalToSuperview().offset(-64)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
        }
        
        let privacyButton = AlternativeButton("Privacy Policy")
        privacyButton.addTarget(self, action: #selector(pressedPrivacy), for: .touchUpInside)
        transluscentView.addSubview(privacyButton)
        privacyButton.snp.makeConstraints { make in
            make.top.equalTo(termsButton.snp.bottom).offset(16)
            make.width.equalToSuperview().offset(-64)
            make.height.equalTo(30)
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
        
        let retryImage = Awesome.Solid.history.asImage(size: buttonSize / 2, color: .themeWhite, backgroundColor: .clear)
        let retryButton = CircleButton(image: retryImage, color: .theme4, size: buttonSize)
        retryButton.addTarget(self, action: #selector(pressedRestore), for: .touchUpInside)
        self.view.addSubview(retryButton)
        retryButton.snp.makeConstraints { make in
            make.bottom.equalTo(transluscentView.snp.top).offset(-16)
            make.right.equalToSuperview().offset(-36)
            make.width.height.equalTo(buttonSize)
        }
        
        
        // person animation
        personAnimation.loopMode = .loop
        personAnimation.animationSpeed = 0.2
        personAnimation.isUserInteractionEnabled = false
        personAnimation.play()
        transluscentView.addSubview(personAnimation)
        personAnimation.snp.makeConstraints { make in
            make.top.equalTo(trialLabel.snp.bottom).priority(.high)
            make.bottom.equalTo(monthlySubButton.snp.top).priority(.high)
            make.width.equalTo(personAnimation.snp.height).priority(.high)
            make.height.greaterThanOrEqualTo(Screen.height / 3.3).priority(.medium)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc func pressedTerms() {
        guard let url = URL(string: "https://dynamicalarmterms.carrd.co") else { return }
        UIApplication.shared.open(url)
    }
    @objc func pressedPrivacy() {
        guard let url = URL(string: "https://dynamicalarmprivacypolicy.carrd.co") else { return }
        UIApplication.shared.open(url)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        personAnimation.play()
        animationView.play()
        scrollView.contentSize = CGSize(width: Screen.width - 64, height: 1000)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    @objc func pressedBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func pressedRestore() {
        Products.store.restorePurchases()
    }
    
    func didFinishPurchase() {
        DispatchQueue.main.async {
            guard let nav = self.navigationController as? AlarmNavigationController else { return }
            let alarmTableView = AlarmTableViewController()
            alarmTableView.delegate = nav
            nav.pushViewController(alarmTableView, animated: true)
            nav.viewControllers = [alarmTableView]
        }
    }
    
    @objc func pressedMonthlyPurchase() {
        if Products.store.isPurchased() {
            didFinishPurchase()
            return
        }
        
        Products.delegate = self
        Products.store.requestProducts(completionHandler: { success,products in
            if success, let product = products?.first(where: {$0.productIdentifier == "03"}) {
                print(product.productIdentifier)
                Products.store.buyProduct(product)
            }
        })
        
    }
    
    @objc func pressedYearlyPurchase() {
        if Products.store.isPurchased() {
            didFinishPurchase()
            return
        }
        
        Products.delegate = self
        Products.store.requestProducts(completionHandler: { success,products in
            if success, let product = products?.first(where: {$0.productIdentifier == "04"}) {
                print(product.productIdentifier)
                Products.store.buyProduct(product)
            }
        })
    }
    
}
