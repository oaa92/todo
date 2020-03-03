//
//  CalendarNotification+CoreDataClass.swift
//  
//
//  Created by Анатолий on 29/02/2020.
//
//

import Foundation
import CoreData

@objc(CalendarNotification)
public class CalendarNotification: NoteNotification {
    func compare(with notification: CalendarNotification) -> Bool {
        if self.date == notification.date,
            self.period == notification.period {
            return true
        } else {
            return false
        }
    }
}
