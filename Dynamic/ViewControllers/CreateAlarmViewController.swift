//
//  CreateAlarmViewController.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/6/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material
import AwesomeEnum
import Lottie

protocol AlarmCreationDelegate {
    func alarmCreated(alarm: Alarm)
}

class CreateAlarmViewController: UIViewController {
    
    var delegate: AlarmCreationDelegate?

    let scrollView = CreateAlarmScrollView()
    
    var alarm : Alarm? {
        didSet {
            if let arrivalTime = alarm?.arrivalTime {
                scrollView.arrivalTimeDatePicker.date = arrivalTime
            }
            if let readyTime = alarm?.readyTime {
                let index = Int(readyTime / 5)
                scrollView.readyTimePicker.segmentController.selectedSegmentIndex = index > 6 ? 6 : index
                scrollView.readyTimePicker.value = readyTime
            }
            scrollView.nextButton.title = "SAVE"
            scrollView.backButton.title = "BACK"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isHeroEnabled = true
        self.view.hero.isEnabled = true
        self.view.backgroundColor = .themeWhite
        
        T.track("Create Alarm View Opened")
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchedView))
        gestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gestureRecognizer)
        
        let topViewOffset = Screen.height * 0.2
        
        let animationView = AnimationView(name: "sun", bundle: Bundle.main)
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        animationView.layer.masksToBounds = true
        animationView.isUserInteractionEnabled = false
        animationView.play()
        self.view.addSubview(animationView)
        let maxWidth = Screen.width
        let ratio : CGFloat = 365.0 / 1080.0
        let height = maxWidth * ratio
        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(height)
            make.width.equalTo(maxWidth)
            make.top.equalToSuperview()
        }
        
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(topViewOffset)
            make.centerX.width.bottom.equalToSuperview()
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: Screen.width, height: (Screen.height * 0.2) + 570.0)
    }
    
    func didPressSaveAlarm(name: String?) {
        if let alarm = self.alarm {
            // Update Alarm
            alarm.shouldSoundWhenPassed = false
            alarm.arrivalTime = scrollView.arrivalTimeDatePicker.date
            alarm.readyTime = scrollView.readyTimePicker.value
            alarm.enabled = true
            alarm.saveAlarm()
            self.delegate?.alarmCreated(alarm: alarm)
            return
        }
        
        let alarm = Alarm(name: name ?? "Alarm",
                          arrivalTime: scrollView.arrivalTimeDatePicker.date,
                          readyTime: scrollView.readyTimePicker.value)
        alarm.saveAlarm()
        self.delegate?.alarmCreated(alarm: alarm)
        
    }
    
    @objc private func touchedView() {
        self.view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
class CreateAlarmScrollView : UIScrollView {
    
    let arrivalTimeDatePicker = DatePicker()
    let readyTimePicker = NumberPicker()
    
    let nextButton = PrimaryButton("CREATE")
    let backButton = AlternativeButton("CANCEL")
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: Screen.width, height: Screen.height * 0.8))
        self.backgroundColor = .themeWhite
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        let arrivalTimeTextView = UIView()
        let arrivalTimeTitle = TitleLabel()
        arrivalTimeTitle.text = "Arrival Time"
        arrivalTimeTitle.textAlignment = .left
        arrivalTimeTextView.addSubview(arrivalTimeTitle)
        arrivalTimeTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.right.left.equalToSuperview()
        }
        
        let arrivalTimeSubtitle = SubtitleLabel()
        arrivalTimeSubtitle.text = "What time do you need to get to your destination?"
        arrivalTimeSubtitle.textAlignment = .left
        arrivalTimeTextView.addSubview(arrivalTimeSubtitle)
        arrivalTimeSubtitle.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.top.equalTo(arrivalTimeTextView.snp.centerY).offset(8)
            make.height.greaterThanOrEqualTo(60)
        }
        
        self.addSubview(arrivalTimeTextView)
        arrivalTimeTextView.snp.makeConstraints { make in
            make.height.equalTo(130)
            make.right.equalToSuperview().offset(-36)
            make.left.equalToSuperview().offset(36)
            make.top.equalToSuperview()
        }
        
        self.addSubview(arrivalTimeDatePicker)
        arrivalTimeDatePicker.snp.makeConstraints { make in
            make.top.equalTo(arrivalTimeTextView.snp.bottom)
            make.left.equalToSuperview().offset(36)
            make.right.equalToSuperview().offset(-72)
            make.height.equalTo(150)
        }
        
        let readyTimeTextView = UIView()
        let readyTimeTitle = TitleLabel()
        readyTimeTitle.text = "Ready Time"
        readyTimeTitle.textAlignment = .left
        readyTimeTextView.addSubview(readyTimeTitle)
        readyTimeTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.right.equalToSuperview()
        }
        
        let readyTimeSubtitle = SubtitleLabel()
        readyTimeSubtitle.text = "How long does it take to get ready?"
        readyTimeSubtitle.textAlignment = .left
        readyTimeTextView.addSubview(readyTimeSubtitle)
        readyTimeSubtitle.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(readyTimeTextView.snp.centerY).offset(8)
        }
        
        self.addSubview(readyTimeTextView)
        readyTimeTextView.isUserInteractionEnabled = false
        readyTimeTextView.snp.makeConstraints { make in
            make.height.equalTo(130)
            make.right.equalToSuperview().offset(-36)
            make.left.equalToSuperview().offset(36)
            make.top.equalTo(arrivalTimeDatePicker.snp.bottom)
        }
        
        self.addSubview(readyTimePicker)
        readyTimePicker.snp.makeConstraints { make in
            make.top.equalTo(readyTimeTextView.snp.bottom)
            make.width.equalToSuperview().offset(-64)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        self.addSubview(nextButton)
        nextButton.makeConstraints(height: 55) { make in
            make.top.equalTo(readyTimePicker.snp.bottom).offset(24)
            make.width.equalToSuperview().offset(-64)
            make.height.equalTo(55)
            make.centerX.equalToSuperview()
        }
        
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        self.addSubview(backButton)
        backButton.makeConstraints(height: 55) { make in
            make.top.equalTo(nextButton.snp.bottom).offset(24)
            make.width.equalToSuperview().offset(-64)
            make.height.equalTo(55)
            make.centerX.equalToSuperview()
        }
        
    }
    
    @objc func nextButtonPressed() {
        guard let vc = self.next?.next as? CreateAlarmViewController else { return }
        if let alarm = vc.alarm {
            vc.didPressSaveAlarm(name: alarm.name)
            return
        }
        vc.showAlarmNameDialog(title: "Create Alarm", message: "What would you like to name your alarm?") { name in
            vc.didPressSaveAlarm(name: name)
        }
    }
    
    @objc func backButtonPressed() {
        guard let vc = self.next?.next as? CreateAlarmViewController else { return }
        vc.navigationController?.popViewController(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
