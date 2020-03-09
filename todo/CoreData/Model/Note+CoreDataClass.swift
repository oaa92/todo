//
//  Note+CoreDataClass.swift
//  todo
//
//  Created by Анатолий on 31/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {
    
    override public func awakeFromInsert() {
        setPrimitiveValue(UUID(), forKey: #keyPath(Note.uid))
        setPrimitiveValue(Date(), forKey: #keyPath(Note.createdAt))
    }
    
    override public func willSave() {
        let now = Date()
        if let updated = updatedAt {
            if now.timeIntervalSince(updated) > 10.0 {
                updatedAt = now
            }
        } else {
            updatedAt = now
        }
    }
    
    func moveToTrash(coreDataStack: CoreDataStack, notificationsManager: NotificationsManager) {
        deletedAt = Date()
        let notifications = (self.notifications ?? []) as! Set<NoteNotification>
        notificationsManager.deregister(notifications: notifications)
    }
}
