//
//  CalendarNotification+CoreDataProperties.swift
//
//
//  Created by Анатолий on 01/03/2020.
//
//

import CoreData
import Foundation

extension CalendarNotification {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CalendarNotification> {
        return NSFetchRequest<CalendarNotification>(entityName: "CalendarNotification")
    }

    @NSManaged public var date: Date?
    @NSManaged public var period: Data?
}
