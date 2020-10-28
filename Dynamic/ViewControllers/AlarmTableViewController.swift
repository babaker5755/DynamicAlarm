//
//  AlarmTableViewController.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/1/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material
import AwesomeEnum

protocol AlarmDelegate {
    func addAlarm()
}

class AlarmTableViewController: UITableViewController {
    
    var delegate : AlarmDelegate?
    
    var alarms : [Alarm] = []
    private let refreshController = UIRefreshControl()
    var addButton : RaisedButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        T.track("Alarm Table View Opened")
        
        self.tableView.contentInset.top = -45
        self.tableView.backgroundView = UIView(frame: self.view.frame)
        self.tableView.backgroundColor = .themeWhite
        self.tableView.separatorStyle = .none
        self.tableView.register(AlarmTableViewCell.self, forCellReuseIdentifier: "alarmCell")
        
        self.tableView.refreshControl = refreshController
        refreshController.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        let width = Screen.width * 2
        let circleLayer = CAShapeLayer()
        let path = UIBezierPath(ovalIn: CGRect(center: CGPoint(x: self.view.bounds.center.x, y: Screen.height + width / 4), size: CGSize(width: width, height: width)))
        circleLayer.fillColor = UIColor.theme4.cgColor
        circleLayer.path = path.cgPath
        self.tableView.backgroundView?.layer.addSublayer(circleLayer)
        
        let buttonSize : CGFloat = 60
        let plusImage = Awesome.Solid.plus.asImage(size: buttonSize / 2, color: .themeWhite, backgroundColor: .clear)
        addButton = CircleButton(image: plusImage, color: .theme1, size: buttonSize)
        
        addButton.addTarget(self, action: #selector(didTouchAddButton), for: .touchUpInside)
        self.navigationController?.view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview().offset(-36)
            make.width.height.equalTo(buttonSize)
        }
        
        refresh()
        
        if !LocalStorage.didTakeTour {
            let spotlightvc = SpotlightTour()
            self.present(spotlightvc, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        addButton.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        addButton.isHidden = false
        self.alarms = LocalStorage.savedAlarms
        self.tableView.reloadData()
    }
    
    func refresh() {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }
    
    @objc func refresh(_ sender: UIRefreshControl?) {
        self.alarms = LocalStorage.savedAlarms
        self.tableView.reloadData()
        DispatchQueue.main.async {
            sender?.endRefreshing()
        }
    }
    
    @objc func didTouchAddButton() {
        delegate?.addAlarm()
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .themeWhite
        let label = TitleLabel("Alarms")
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(16)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ?  105 : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath) as? AlarmTableViewCell else { return UITableViewCell()}
        cell.selectionStyle = .none
        cell.alarm = alarms[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nav = self.navigationController else { return }
        let alarmDetailVc = AlarmDetailTableViewController()
        alarmDetailVc.alarm = alarms[indexPath.row]
        nav.heroNavigationAnimationType = .selectBy(presenting: .cover(direction: .left), dismissing: .uncover(direction: .right))
        nav.pushViewController(alarmDetailVc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let id = alarms[indexPath.row].id
            guard let index = LocalStorage.savedAlarms.firstIndex(where: { $0.id == id }) else { return }
            LocalStorage.savedAlarms.remove(at: index)
            alarms.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            ScheduledNotification.clearOldAlarms()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
}
