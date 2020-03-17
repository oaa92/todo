//
//  Note+CoreDataClass.swift
//  todo
//
//  Created by Анатолий on 31/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//
//

import CoreData
import Foundation

@objc(Note)
public class Note: NSManagedObject {
    public override func awakeFromInsert() {
        setPrimitiveValue(UUID(), forKey: #keyPath(Note.uid))
        setPrimitiveValue(Date(), forKey: #keyPath(Note.createdAt))
    }
    
    public override func willSave() {
        let now = Date()
        if let updated = updatedAt {
            if now.timeIntervalSince(updated) > 10.0 {
                updatedAt = now
            }
        } else {
            updatedAt = now
        }
    }
    
    // MARK: Set properties
    
    func setBackground(_ coreDataStack: CoreDataStack, background newBackground: GradientBackgroud) {
        if let background = background,
            newBackground.compare(with: background) {
            return
        }
        // search background in storage
        let setBackground: GradientBackgroud
        if let equalBackground = newBackground.searchEqualBackground(coreDataStack) {
            setBackground = equalBackground
        } else {
            coreDataStack.managedContext.insert(newBackground)
            setBackground = newBackground
        }
        deleteBackgroundIfNeeded(coreDataStack)
        background = setBackground
    }
    
    private func deleteBackgroundIfNeeded(_ coreDataStack: CoreDataStack) {
        guard let background = background else {
            return
        }
        self.background = nil
        background.deleteIfNeeded(coreDataStack)
    }
    
    func setTags(_ coreDataStack: CoreDataStack, tags newTags: Set<Tag>) {
        let tags = self.tags as! Set<Tag>
        let tagsRem = tags.subtracting(newTags)
        let tagsAdd = newTags.subtracting(tags)
        
        guard tagsRem.count > 0 || tagsAdd.count > 0 else {
            return
        }
        removeFromTags(tagsRem as NSSet)
        addToTags(tagsAdd as NSSet)
    }
    
    func setNotifications(_ coreDataStack: CoreDataStack, notifications newNotifications: Set<NoteNotification>) -> ([CalendarNotification], [String]) {
        let currentNotifications = notifications as! Set<NoteNotification>
        let calendarCurrentNotifications = currentNotifications.compactMap { $0 as? CalendarNotification }
        let calendarSavedNotifications = newNotifications.compactMap { $0 as? CalendarNotification }
        
        var notificationsRem: Set<NoteNotification> = []
        let remArr = CalendarNotification.subtracting(a: calendarCurrentNotifications, b: calendarSavedNotifications)
        remArr.forEach { notificationsRem.insert($0) }
        
        var notificationsAdd: Set<NoteNotification> = []
        let addArr = CalendarNotification.subtracting(a: calendarSavedNotifications, b: calendarCurrentNotifications)
        addArr.forEach { notificationsAdd.insert($0) }
        
        guard notificationsRem.count > 0 || notificationsAdd.count > 0 else {
            return ([], [])
        }
        
        notificationsAdd.forEach { coreDataStack.managedContext.insert($0) }
        removeFromNotifications(notificationsRem as NSSet)
        addToNotifications(notificationsAdd as NSSet)
        
        notificationsRem.forEach {
            $0.delete(coreDataStack)
        }
        return (notificationsAdd.compactMap { $0 as? CalendarNotification },
                notificationsRem.compactMap { $0.uid })
    }
    
    // MARK: Delete note
    
    func moveToTrash(_ coreDataStack: CoreDataStack) -> [String] {
        deletedAt = Date()
        let notifications = (self.notifications ?? []) as! Set<NoteNotification>
        notifications.forEach { $0.delete(coreDataStack) }
        return notifications.compactMap { $0.uid }
    }
    
    func delete(coreDataStack: CoreDataStack) {
        deleteBackgroundIfNeeded(coreDataStack)
        coreDataStack.managedContext.delete(self)
    }
}
