//
//  AlarmDetailTableViewController.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/2/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material
import AwesomeEnum
import AVFoundation


protocol TripDelegate {
    func addTrip()
}

class AlarmDetailTableViewController: UITableViewController, AlarmCreationDelegate, TripCreationDelegate, TripDelegate, SettingsDelegate, SettingModalDelegate, TripUpdateDelegate {
    
    var alarm : Alarm!
    var trips : [Trip] = []
    
    var backButton = RaisedButton()
    var previewButton = RaisedButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .themeWhite
        
        T.track("Alarm Detail View Opened")
        
        self.tableView.separatorStyle = .none
        self.tableView.register(AlarmDetailTableViewCell.self, forCellReuseIdentifier: "alarmDetailCell")
        self.tableView.register(AddAStopTableViewCell.self, forCellReuseIdentifier: "stopDetailCell")
        self.tableView.register(TripDetailTableViewCell.self, forCellReuseIdentifier: "tripDetailCell")
        self.tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "settingsDetailCell")
        
        self.tableView.contentInset.top = -45
        self.tableView.backgroundView = UIView(frame: self.view.frame)
        
        let width = Screen.width * 2
        let circleLayer = CAShapeLayer()
        let path = UIBezierPath(ovalIn: CGRect(center: CGPoint(x: self.view.bounds.center.x, y: Screen.height + width / 4), size: CGSize(width: width, height: width)))
        circleLayer.fillColor = UIColor.theme1.cgColor
        circleLayer.path = path.cgPath
        self.tableView.backgroundView?.layer.addSublayer(circleLayer)
        
        let buttonSize : CGFloat = 60
        let plusImage = Awesome.Solid.chevronLeft.asImage(size: buttonSize / 2, color: .themeWhite, backgroundColor: .clear)
        backButton = CircleButton(image: plusImage, color: .theme4, size: buttonSize)
        backButton.isHidden = false
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        self.navigationController?.view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-36)
            make.left.equalToSuperview().offset(36)
            make.width.height.equalTo(buttonSize)
        }
        
        let previewImage = Awesome.Solid.playCircle.asImage(size: buttonSize / 2, color: .themeWhite, backgroundColor: .clear)
        previewButton = CircleButton(image: previewImage, color: .theme4, size: buttonSize)
        previewButton.isHidden = false
        previewButton.addTarget(self, action: #selector(playSound), for: .touchUpInside)
        self.navigationController?.view.addSubview(previewButton)
        previewButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-36)
            make.right.equalToSuperview().offset(-36)
            make.width.height.equalTo(buttonSize)
        }
        
        updateCells()
    }
    
    @objc func playSound() {
        let manager = SoundManager.instance
        if manager.isPlaying() {
            manager.stopSound()
            return
        }
        manager.playSound(alarm: alarm, volume: alarm.volume.getValue())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backButton.isHidden = false
        previewButton.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        backButton.isHidden = true
        previewButton.isHidden = true
    }
    
    func updateCells() {
        let trips = alarm.tripObjects ?? []
        self.trips = trips
        trips.forEach { trip in
            trip.tripUpdateDelegate = self
        }
        tableView.reloadData()
    }
    
    func alarmCreated(alarm: Alarm) {
        self.navigationController?.popViewController(animated: true)
        self.tableView.reloadData()
    }
    
    func tripPressedBack(alarm: Alarm) {
        self.navigationController?.popViewController(animated: true)
        tableView.reloadData()
    }
    
    func tripCreated(alarm: Alarm, trip: Trip?) {
        self.navigationController?.popViewController(animated: true)
        updateCells()
    }
    
    func addTrip() {
        let vc = CreateTripViewController()
        vc.alarm = alarm
        vc.startAddress = trips.last?.endAddress
        vc.tripDelegate = self
        vc.delegate = self
        push(vc)
    }
    
    func didPressSettingButton(_ type: SettingType) {
        let modal = SettingsTableView()
        modal.delegate = self
        modal.type = type
        modal.alarm = alarm
        self.present(modal, animated: true, completion: nil)
    }
    
    func didChangeSetting() {
        tableView.reloadData()
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func travelTimeUpdated() {
        updateCells()
    }
    
    func push(_ vc : UIViewController) {
        guard let nav = self.navigationController else { return }
        nav.heroNavigationAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
        nav.pushViewController(vc, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        let view = UIView()
        view.backgroundColor = .themeWhite
        let label = TitleLabel("Alarm Details")
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(16)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 105 : 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            // Alarm Cell
            return 170
        case 1:
            // Main Trip Cell
            return 120 + (CGFloat(trips.count) * 50.0)
        case 2:
            // Add Trip Cell
            return 70
        case 3:
            // Settings Cell
            return 130
        default:return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return (alarm.trips.count == 0) ? 0 : 1
        case 2: return 1
        case 3: return 2
        default:return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let vc = CreateAlarmViewController()
            vc.delegate = self
            vc.alarm = alarm
            push(vc)
        case 1:
            let vc = CreateTripViewController()
            vc.trip?.tripUpdateDelegate = self
            vc.trip = trips.last
            vc.alarm = alarm
            vc.delegate = self
            push(vc)
        default:return
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title:  "") { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.tableView(self.tableView, commit: .delete, forRowAt: indexPath)
            success(true)
        }
        
        deleteAction.image = Awesome.Solid.trashAlt.asImage(size: 32, color: .red, backgroundColor: .clear)
        deleteAction.backgroundColor = UIColor.init(white: 1, alpha: 0)

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showAlert(title: "Remove Trip", message: "Are you sure you want to remove a trip?", buttonTitle: "Yes", completion: { [weak self] in
                self?.alarm.trips.removeLast()
                self?.alarm.saveAlarm()
                self?.tableView.reloadData()
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "alarmDetailCell",
                                                     for: indexPath) as! AlarmDetailTableViewCell
            cell.alarm = self.alarm
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "tripDetailCell", for: indexPath) as! TripDetailTableViewCell
            cell.alarm = alarm
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stopDetailCell",
                                                     for: indexPath) as! AddAStopTableViewCell
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsDetailCell", for: indexPath) as! SettingsTableViewCell
            cell.delegate = self
            cell.alarm = self.alarm
            switch indexPath.row {
            case 0:
                cell.types = [.sound, .volume]
                return cell
            case 1:
                cell.types = [.repeating, .snooze]
                return cell
            default:break
            }
        default:break
        }
        return UITableViewCell()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
}
