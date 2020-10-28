//
//  CreateTripViewController.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/6/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material
import AwesomeEnum
import Hero

protocol TripCreationDelegate {
    func tripCreated(alarm: Alarm, trip: Trip?)
    func tripPressedBack(alarm: Alarm)
}

class CreateTripViewController: UIViewController, UITextFieldDelegate, AddressFieldDelegate, TransportTypeDelegate {
    
    var alarm : Alarm!
    
    var delegate: TripCreationDelegate?
    
    var startAddress : Location?
    
    var tripDelegate : TripUpdateDelegate?
    
    let scrollView = CreateTripScrollView()
    
    var trip : Trip? {
        didSet {
            if let start = trip?.startAddress {
                scrollView.startAddressField.selectedMapItem = start
                scrollView.startAddressField.textField.textField.text = start.name
            }
            if let end = trip?.endAddress {
                scrollView.endAddressField.selectedMapItem = end
                scrollView.endAddressField.textField.textField.text = end.name
            }
            if let bufferTime = trip?.bufferTime {
                let index = Int(bufferTime / 5)
                scrollView.bufferTimePicker.segmentController.selectedSegmentIndex = index > 6 ? 6 : index
                scrollView.bufferTimePicker.value = bufferTime
            }
            if let transportType = trip?.transportType {
                if transportType == .automobile {
                    scrollView.transportTypeView.carSelected()
                } else {
                    scrollView.transportTypeView.walkSelected()
                }
            }
            updateTravelTime()
            scrollView.nextButton.title = "SAVE"
            scrollView.backButton.title = "BACK"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isHeroEnabled = true
        self.view.backgroundColor = .themeWhite
        
        T.track("Create Trip View Opened")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupViews()
        
        if let startAddress = startAddress {
            scrollView.startAddressField.textField.textField.text = startAddress.name
            scrollView.startAddressField.selectedMapItem = startAddress
            self.startAddress = nil
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTravelTime()
        setupViews()
    }
    
    func setupViews() {
        self.scrollView.removeFromSuperview()
        self.view.addSubview(scrollView)
        scrollView.setupViews()
        scrollView.contentSize = CGSize(width: Screen.width, height: 850)
    }
    
    func updateTravelTime() {
        if let start = scrollView.startAddressField.selectedMapItem,
            let end = scrollView.endAddressField.selectedMapItem {
            let transportType = scrollView.transportTypeView.selectedType
            DirectionManager.getEstimatedTravelTime(transportType: transportType, start: start, end: end) { result in
                guard let result = result else { return }
                let timeInMinutes = result / 60
                print("estimatedTravelTime: \(timeInMinutes) minutes")
                self.scrollView.timeLabel.text = "\(timeInMinutes.getString(0)) minutes"
            }
        } else {
            scrollView.timeLabel.text = nil
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func didTapTextField(_ textField: UITextField) {
        guard navigationController?.topViewController == self else { return }
        let mapViewController = MapViewController()
        let field = scrollView.startAddressField.textField.textField == textField ? scrollView.startAddressField : scrollView.endAddressField
        mapViewController.setAddressField(field)
        mapViewController.isHeroEnabled = true
        mapViewController.delegate = field
        navigationController?.heroNavigationAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
        navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    func didSelectAddress(_ location: Location) {
        self.view.endEditing(true)
        updateTravelTime()
    }
    
    func didSetTransportType() {
        updateTravelTime()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height / 3
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func nextButtonPressed() {
        guard let start = scrollView.startAddressField.selectedMapItem, let end = scrollView.endAddressField.selectedMapItem else {
            showAlert(title: "No Locations Selected",
                      message: "Continue without adding a trip to your alarm?",
                      buttonTitle: "Continue"
            ) { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                self.delegate?.tripCreated(alarm: self.alarm, trip: nil)
            }
            return
        }
        
        let transportType = scrollView.transportTypeView.selectedType
        let bufferTime = scrollView.bufferTimePicker.value
        
        if let trip = self.trip {
            // Editing trip
            trip.bufferTime = bufferTime
            trip.transportType = transportType
            trip.startAddress = start
            trip.endAddress = end
            trip.updateTravelTime(alarm: alarm)
            alarm.updateTrip(trip: trip)
            delegate?.tripCreated(alarm: alarm, trip: trip)
            return
        }
        
        let trip = Trip(alarm: self.alarm, startAddress: start, endAddress: end, transportType: transportType, bufferTime: bufferTime)
        trip.tripUpdateDelegate = tripDelegate
        alarm.addTrip(trip: trip)
        delegate?.tripCreated(alarm: alarm, trip: trip)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    @objc func backButtonPressed() {
        delegate?.tripPressedBack(alarm: alarm)
    }


    @objc private func touchedView() {
        self.view.endEditing(true)
    }
}

class CreateTripScrollView : UIScrollView {
    
    let timeLabel = SubtitleLabel()
    let estimatedTimeLabel = SubtitleLabel("Estimated Travel Time:")
    let transportTypeView = TranportationTypeView()
    let startAddressField = AddressTextField("Start Address")
    let endAddressField = AddressTextField("End Address")
    let bufferTimePicker = NumberPicker()

    let nextButton = PrimaryButton("FINISH")
    let backButton = AlternativeButton("BACK")
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: Screen.width, height: Screen.height))
        self.backgroundColor = .themeWhite
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
    
    func setupViews() {
        
        let titleLabel = TitleLabel("Trip Info")
        titleLabel.textAlignment = .left
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(72)
            make.left.equalToSuperview().offset(32)
        }
        
        if let vc = self.next?.next as? CreateTripViewController {
            transportTypeView.delegate = vc
        }
        
        self.addSubview(transportTypeView)
        transportTypeView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
        }
        
        guard let vc = self.next?.next as? CreateTripViewController else { return }
        startAddressField.textField.textField.returnKeyType = .done
        startAddressField.textField.textField.delegate = vc
        startAddressField.delegate = vc
        self.addSubview(startAddressField)
        startAddressField.snp.makeConstraints { make in
            make.top.equalTo(transportTypeView.snp.bottom).offset(60)
            make.width.equalToSuperview().offset(-64)
            make.centerX.equalToSuperview()
            make.height.equalTo(75)
        }
        
        endAddressField.textField.textField.returnKeyType = .done
        endAddressField.textField.textField.delegate = vc
        endAddressField.delegate = vc
        self.addSubview(endAddressField)
        endAddressField.snp.makeConstraints { make in
            make.top.equalTo(startAddressField.snp.bottom).offset(48)
            make.width.equalToSuperview().offset(-64)
            make.centerX.equalToSuperview()
            make.height.equalTo(75)
        }
        
        estimatedTimeLabel.textAlignment = .left
        self.addSubview(estimatedTimeLabel)
        estimatedTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(endAddressField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-64)
        }
        
        timeLabel.textColor = UIColor.black.darker()
        timeLabel.font = .systemFont(ofSize: 18, weight: .medium)
        timeLabel.textAlignment = .right
        self.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(endAddressField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-64)
        }
        
        let bufferLabel = SubtitleLabel()
        bufferLabel.text = "Buffer Time"
        bufferLabel.textAlignment = .left
        self.addSubview(bufferLabel)
        bufferLabel.snp.makeConstraints { make in
            make.top.equalTo(estimatedTimeLabel.snp.bottom).offset(24)
            make.width.equalToSuperview().offset(-64)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(bufferTimePicker)
        bufferTimePicker.snp.makeConstraints { make in
            make.top.equalTo(bufferLabel.snp.bottom).offset(24)
            make.width.equalToSuperview().offset(-64)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        self.addSubview(nextButton)
        nextButton.makeConstraints(height: 55) { make in
            make.top.equalTo(bufferTimePicker.snp.bottom).offset(24)
            make.width.equalToSuperview().offset(-64)
            make.centerX.equalToSuperview()
            make.height.equalTo(55)
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
        guard let vc = self.next?.next as? CreateTripViewController else { return }
        vc.nextButtonPressed()
    }
    
    @objc func backButtonPressed() {
        guard let vc = self.next?.next as? CreateTripViewController else { return }
        vc.backButtonPressed()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
