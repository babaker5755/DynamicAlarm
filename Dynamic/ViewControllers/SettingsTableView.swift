//
//  SettingsTableView.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/9/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material

protocol SettingModalDelegate {
    func didChangeSetting()
}

class SettingsTableView: HalfScreenModalViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    let titleLabel = TitleLabel()
    var dataSource : [String] = []
    var delegate : SettingModalDelegate?
    
    var type : SettingType?
    var alarm : Alarm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(8)
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .themeWhite
        self.mainView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.height.equalToSuperview().offset(-32)
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(60)
        }
        
        setupDataSource()
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissAndRefresh()
    }
    
    func setupDataSource() {
        guard let type = type else { return }
        switch type {
        case .sound:
            dataSource = Sound.allCases.map { $0.name() }
        case .volume:
            dataSource = Volume.allCases.map { $0.rawValue }
        case .repeating:
            dataSource = RepeatDay.allCases.map { $0.rawValue }
        case .snooze:
            dataSource = Snooze.allCases.map { $0.rawValue }
        }
        tableView.reloadData()
    }
    
    func setupViews() {
        guard let type = self.type else { return }
        titleLabel.text = type.rawValue
        tableView.allowsMultipleSelection = type == .repeating
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = dataSource[indexPath.row]
        cell.textLabel?.textColor = .blackText
        cell.backgroundColor = .themeWhite
        let value = dataSource[indexPath.row]
        guard let type = type else { return cell }
        switch type {
        case .repeating:
            cell.accessoryType = alarm.repeating.contains(where: {$0.rawValue == value }) ? .checkmark : .none
        case .sound:
            cell.accessoryType = alarm.sound.name() == value ? .checkmark : .none
        case .volume:
            cell.accessoryType = alarm.volume.rawValue == value ? .checkmark : .none
        case .snooze:
            cell.accessoryType = alarm.snooze.rawValue == value ? .checkmark : .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = type else { return }
        switch type {
        case .sound:
            if let cell = tableView.cellForRow(at: indexPath),
                let selectedSound = cell.textLabel?.text,
                let sound = Sound.allCases.first(where: { $0.name() == selectedSound }){
                alarm.sound = sound
                alarm.saveAlarm()
            }
            dismissAndRefresh()
        case .volume:
            if let cell = tableView.cellForRow(at: indexPath),
                let selectedVolume = cell.textLabel?.text,
                let volume = Volume.allCases.first(where: { $0.rawValue == selectedVolume }){
                alarm.volume = volume
                alarm.saveAlarm()
            }
            dismissAndRefresh()
        case .repeating:
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
                let selectedDay = cell.textLabel?.text
                if !alarm.repeating.contains(where: { repeatDay in
                    repeatDay.rawValue == selectedDay
                }) {
                    if let selectedDay = RepeatDay.allCases.first(where: { $0.rawValue == selectedDay }) {
                        alarm.repeating.append(selectedDay)
                        alarm.saveAlarm()
                    }
                }
            }
        case .snooze:
            if let cell = tableView.cellForRow(at: indexPath),
                let selectedSnooze = cell.textLabel?.text,
                let snooze = Snooze.allCases.first(where: {$0.rawValue == selectedSnooze }){
                alarm.snooze = snooze
                alarm.saveAlarm()
            }
            dismissAndRefresh()
        }
    }
    
    func dismissAndRefresh() {
        delegate?.didChangeSetting()
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let type = type else { return }
        if let cell = tableView.cellForRow(at: indexPath), type == .repeating {
            cell.accessoryType = .none
            if let index = alarm.repeating.firstIndex(where: { $0.rawValue == cell.textLabel?.text }) {
                alarm.repeating.remove(at: index)
                alarm.saveAlarm()
            }
            
        }
    }
    
    
}
