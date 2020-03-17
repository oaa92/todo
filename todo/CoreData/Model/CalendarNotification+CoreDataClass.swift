//
//  CalendarNotification+CoreDataClass.swift
//
//
//  Created by Анатолий on 29/02/2020.
//
//

import CoreData
import Foundation

@objc(CalendarNotification)
public class CalendarNotification: NoteNotification {
    var getPeriod: PeriodType? {
        if let data = period {
            return try? JSONDecoder().decode(PeriodType.self, from: data)
        }
        return nil
    }

    func compare(with notification: CalendarNotification) -> Bool {
        if self.date == notification.date,
            self.period == notification.period {
            return true
        } else {
            return false
        }
    }
}

extension CalendarNotification {
    static func createWithParams(entity: NSEntityDescription? = nil,
                                 context: NSManagedObjectContext? = nil,
                                 date: Date,
                                 period: PeriodType) -> CalendarNotification? {
        let encoder = JSONEncoder()
        let data: Data
        do {
            data = try encoder.encode(period)
        } catch {
            print(error.localizedDescription)
            return nil
        }

        let notification = CalendarNotification(entity: entity ?? CalendarNotification.entity(),
                                                insertInto: context)
        notification.uid = UUID().uuidString
        notification.date = date
        notification.period = data
        return notification
    }

    static func subtracting(a: [CalendarNotification],
                            b: [CalendarNotification]) -> [CalendarNotification] {
        var result: [CalendarNotification] = []
        for notification in a {
            let isContains = b.contains { $0.compare(with: notification) }
            if !isContains {
                result.append(notification)
            }
        }
        return result
    }
}
