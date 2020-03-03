//
//  NotificationsManager.swift
//  todo
//
//  Created by Анатолий on 23/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UserNotifications

class NotificationsManager: NSObject {
    var notificationGranted: Bool = false
    let center = UNUserNotificationCenter.current()

    override init() {
        super.init()
        center.delegate = self
    }

    func authorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            self.notificationGranted = granted
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func printNextData() {
        center.getPendingNotificationRequests {
            notifications in
            for notification in notifications {
                let trigger = notification.trigger as! UNCalendarNotificationTrigger
                var nextDateStr = "?"
                if let nextDate = trigger.nextTriggerDate() {
                    nextDateStr = DateFormatter.localizedString(from: nextDate, dateStyle: .full, timeStyle: .full)
                }
                print("id: \(notification.identifier) next date: \(nextDateStr)")
            }
        }
    }

    func create(identifier: String, title: String? = nil, body: String, dateInfo: DateComponents, repeats: Bool, completion: ((Error?) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        if let title = title {
            content.title = title
        }
        content.body = body
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: completion)
    }
}

extension NotificationsManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {}

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}
