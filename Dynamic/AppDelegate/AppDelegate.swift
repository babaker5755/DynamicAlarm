//
//  AppDelegate.swift
//  Dynamic
//
//  Created by Brandon Baker on 4/29/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import StoreKit
import SwiftKeychainWrapper
import Mixpanel

let db = Firestore.firestore()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        SKPaymentQueue.default().add(self)
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        Mixpanel.initialize(token: Secrets.mixPanel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didTakeScreenshot),name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(reinstateBackgroundTask),name: UIApplication.didBecomeActiveNotification, object: nil)
        
        return true
    }
    
    // Allows family to get access for free by
    // taking a screenshot. Add their uid to "fam" table
    // in firestore.
    @objc func didTakeScreenshot() {
        guard let fcmToken = LocalStorage.fcmToken else { return }
        db.collection("fam").document(fcmToken).getDocument { (doc, error) in
            if let doc = doc, doc.exists {
                LocalStorage.shouldBeFree = true
            } else {
                db.collection("potentialFam").document(fcmToken).setData(["token": fcmToken])
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        Mixpanel.mainInstance().identify(distinctId: fcmToken)

        db.collection("users").document(fcmToken).setData([ "token": fcmToken ], merge: true)
        
        let dataDict:[String: String] = ["token": fcmToken]
        
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        LocalStorage.fcmToken = fcmToken
        
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
        
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        
        // Check if silent notification
        if aps["content-available"] as? Int == 1 {
            print("silent notification - fetching data")
            Alarm.refetchActiveAlarmData()
            if let alarmId = userInfo["alarmId"] as? String,
                let alarm = LocalStorage.savedAlarms.first(where: {$0.id == alarmId}) {
                print("setting active alarm")
                AlarmHandler.instance.activeAlarm = alarm
            }
            completionHandler(.newData)
        } else {
            if let alarmId = userInfo["alarmId"] as? String,
                let alarm = LocalStorage.savedAlarms.first(where: {$0.id == alarmId}) {
                alarm.soundAlarm(1)
                AlarmHandler.instance.activeAlarm = alarm
            }
            completionHandler(.newData)
        }
    }
    
    @objc func willResignActive(_ notification: Notification) {
        sendAppClosedNotification()
        cleanUpTrips()
    }
    
    @objc func reinstateBackgroundTask() {
        if ScheduledNotification.backgroundTask == .invalid {
            ScheduledNotification.registerBackgroundTask()
        }
    }
    
    func cleanUpTrips() {
        LocalStorage.savedTrips.removeAll(where: { trip in
            var tripBelongsToAlarm = false
            LocalStorage.savedAlarms.forEach { alarm in
                if alarm.trips.contains(trip.id) {
                    tripBelongsToAlarm = true
                }
            }
            return !tripBelongsToAlarm
        })
        print(LocalStorage.savedTrips)
    }
    
    func sendAppClosedNotification() {
        guard let token = LocalStorage.fcmToken else { return }
        let url = URL(string: Secrets.appClosedRoute)!
        var request = URLRequest(url: url)
        let json: [String: String] =  ["id":token]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in }
        task.resume()
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        sendAppClosedNotification()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
}


// MARK: SKPayment Tranaction

extension AppDelegate : SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                completeTransaction(transaction)
            case .failed:
                failedTransaction(transaction)
            default:
                print("unhandled transaction")
            }
        }
    }
    
    func completeTransaction(_ transaction: SKPaymentTransaction) {
        T.track("Subscription Purchased")
        KeychainWrapper.standard.set(true, forKey: transaction.payment.productIdentifier)
        deliverPurchaseNotification(for: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func failedTransaction(_ transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError?,
            let desc = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("transactionError: \(desc)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func deliverPurchaseNotification(for identifier: String?) {
        guard let identifier = identifier else { return }
        NotificationCenter.default.post(name: .purchaseNotification, object: identifier)
        Products.handlePurchase(purchaseIdentifier: identifier)
    }
}

extension Notification.Name {
    static let purchaseNotification = Notification.Name("PurchaseNotification")
}

