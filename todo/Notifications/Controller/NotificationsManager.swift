//
//  NotificationsManager.swift
//  todo
//
//  Created by Анатолий on 23/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UserNotifications
import CoreData
import UIKit

class NotificationsManager: NSObject {
    var locale: Locale!
    var coreDataStack: CoreDataStack!
    var window: UIWindow?
    
    private var notificationGranted: Bool = false
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

    func printNextDate() {
        center.getPendingNotificationRequests {
            notifications in
            for notification in notifications {
                let trigger = notification.trigger as! UNCalendarNotificationTrigger
                var nextDateStr = "?"
                if let nextDate = trigger.nextTriggerDate() {
                    nextDateStr = DateFormatter.localizedString(from: nextDate, dateStyle: .full, timeStyle: .full)
                }
                print("NND id: \(notification.identifier) next date: \(nextDateStr)")
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

// MARK: UNUserNotificationCenterDelegate

extension NotificationsManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        do {
            let fetchRequest: NSFetchRequest<CalendarNotification> = CalendarNotification.fetchRequest()
            let predicate = NSPredicate(format: "%K = %@", #keyPath(CalendarNotification.uid), identifier)
            fetchRequest.predicate = predicate
            let notifications = try coreDataStack.managedContext.fetch(fetchRequest)
            if let note = notifications.first?.note {
                let noteController = NoteViewController()
                noteController.locale = locale
                noteController.coreDataStack = coreDataStack
                noteController.notificationsManager = self
                noteController.note = note
                if let navigationController = window?.rootViewController as? UINavigationController {
                    navigationController.pushViewController(noteController, animated: true)
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

// MARK: CalendarNotifications

extension NotificationsManager {
    func register(notifications: [CalendarNotification]) {
        guard notificationGranted else {
            return
        }
        
        for notification in notifications {
            if let uid = notification.uid,
                let date = notification.date,
                let data = notification.period,
                let period = try? JSONDecoder().decode(PeriodType.self, from: data) {
                
                let message = "🔔"
                let dateInfo = getDateComponents(date: date, period: period)
                let repeats = period == .none ? false : true

                create(identifier: uid, body: message, dateInfo: dateInfo, repeats: repeats)
            }
        }
    }
    
    private func getDateComponents(date: Date, period: PeriodType) -> DateComponents {
        var newComponents = DateComponents()
        let components = locale.calendar.dateComponents([.day, .month, .year, .hour, .minute, .weekday], from: date)
        switch period {
        case .none:
            newComponents.day = components.day
            newComponents.month = components.month
            newComponents.year = components.year
        case let .weekly(weekdays: weekdays):
            if let weekdays = weekdays {
                newComponents.weekday = weekdays[0]
            }
        case .monthly:
            newComponents.day = components.day
        case .annually:
            newComponents.month = components.month
            newComponents.day = components.day
        default:
            break
        }
        newComponents.hour = components.hour
        newComponents.minute = components.minute
        return newComponents
    }
    
    func deregister(notifications: Set<NoteNotification>) {
        let ids = notifications.compactMap { $0.uid }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
