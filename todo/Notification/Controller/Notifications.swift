//
//  Notifications.swift
//  todo
//
//  Created by Анатолий on 23/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UserNotifications

class Notifications: NSObject {
    let center = UNUserNotificationCenter.current()

    override init() {
        super.init()
        center.delegate = self
    }

    func authorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (_: Bool, error: Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }

    func create(identifier: String, title: String? = nil, body: String, dateInfo: DateComponents, repeats: Bool) {
        let content = UNMutableNotificationContent()
        if let title = title {
            content.title = title
        }
        content.body = body
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request) { (error: Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
}

extension Notifications: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {}

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}
