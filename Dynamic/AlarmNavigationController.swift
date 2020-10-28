//
//  NavigationController.swift
//  Dynamic
//
//  Created by Brandon Baker on 4/29/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Hero
import Material
import AwesomeSpotlightView
import MapKit

class AlarmNavigationController: UINavigationController, AlarmCreationDelegate, AlarmDelegate, TripCreationDelegate, AlarmHandlerDelegate {
    
    var currentQuestionIndex = 0

    var spotlightView = AwesomeSpotlightView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .themeWhite
        self.isHeroEnabled = true
        self.isNavigationBarHidden = true
        AlarmHandler.instance.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AlarmHandler.instance.delegate = self
    }
    
    func addAlarm() {
        let alarmVc = CreateAlarmViewController()
        alarmVc.delegate = self
        self.heroNavigationAnimationType = .push(direction: .left)
        self.pushViewController(alarmVc, animated: true)
    }
    
    func tripCreated(alarm: Alarm, trip: Trip?) {
        let alarmTableView = AlarmTableViewController()
        alarmTableView.delegate = self
        
        let alarmDetailVc = AlarmDetailTableViewController()
        alarmDetailVc.alarm = alarm
        self.heroNavigationAnimationType = .selectBy(presenting: .cover(direction: .left), dismissing: .uncover(direction: .right))
        self.pushViewController(alarmDetailVc, animated: true)
        
        self.viewControllers = [alarmTableView, alarmDetailVc]
    }
    
    func tripPressedBack(alarm: Alarm) {
        let count = self.viewControllers.count
        if let lastViewController = self.viewControllers[count - 2] as? CreateAlarmViewController {
            lastViewController.alarm = alarm
        }
        popViewController(animated: true)
    }
    
    func alarmCreated(alarm: Alarm) {
        let tripVc = CreateTripViewController()
        tripVc.alarm = alarm
        tripVc.delegate = self
        self.heroNavigationAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .push(direction: .left))
        self.pushViewController(tripVc, animated: true)
    }
    
    func showAlarmDismissalView(_ alarm: Alarm) {
        let vc = AlarmDismissalViewController()
        vc.alarm = alarm
        self.isHeroEnabled = true
        self.heroNavigationAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
        self.pushViewController(vc, animated: true)
    }
    
    func openMap(for trip: Trip) {

        let start = trip.startAddress
        let end = trip.endAddress
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: start.latitude, longitude: start.longitude)))
        source.name = start.name

        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: end.latitude, longitude: end.longitude)))
        destination.name = end.name

        let mode = trip.transportType == .automobile ? MKLaunchOptionsDirectionsModeDriving : MKLaunchOptionsDirectionsModeWalking
        MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: mode])
        
    }
    
    
}

