//
//  Note+CoreDataProperties.swift
//
//
//  Created by Анатолий on 29/02/2020.
//
//

import CoreData
import Foundation

extension Note {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var uid: UUID?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var background: GradientBackgroud?
    @NSManaged public var tags: NSSet?
    @NSManaged public var notifications: NSSet?
}

// MARK: Generated accessors for tags

extension Note {
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}

// MARK: Generated accessors for notifications

extension Note {
    @objc(addNotificationsObject:)
    @NSManaged public func addToNotifications(_ value: NoteNotification)

    @objc(removeNotificationsObject:)
    @NSManaged public func removeFromNotifications(_ value: NoteNotification)

    @objc(addNotifications:)
    @NSManaged public func addToNotifications(_ values: NSSet)

    @objc(removeNotifications:)
    @NSManaged public func removeFromNotifications(_ values: NSSet)
}
