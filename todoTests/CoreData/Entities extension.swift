//
//  Entities extension.swift
//  todoTests
//
//  Created by Анатолий on 14/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
@testable import todo

extension NSManagedObject {
    static func flush(_ coreDataStack: TestCoreDataStack, objBlock: (NSManagedObject) -> ()) {
        let entityName = self.description()
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let objs = try! coreDataStack.managedContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            objBlock(obj)
            coreDataStack.managedContext.delete(obj)
        }
    }
}

extension Tag {
    static func flush(_ coreDataStack: TestCoreDataStack) {
        super.flush(coreDataStack) {
            obj in
            if let tag = obj as? Tag {
                tag.icon = nil
            }
        }
    }
}

extension Icon {
    static func flush(_ coreDataStack: TestCoreDataStack) {
        super.flush(coreDataStack) {
            obj in
            if let icon = obj as? Icon,
                let tags = icon.tags {
                icon.removeFromTags(tags)
            }
        }
    }
}

extension GradientBackgroud {
    static func flush(_ coreDataStack: TestCoreDataStack) {
        super.flush(coreDataStack) {
            obj in
            if let background = obj as? GradientBackgroud,
                let notes = background.notes {
                background.removeFromNotes(notes)
            }
        }
    }
}

extension Note {
    static func flush(_ coreDataStack: TestCoreDataStack) {
        super.flush(coreDataStack) {
            obj in
            if let note = obj as? Note {
                note.background = nil
                if let tags = note.tags {
                    note.removeFromTags(tags)
                }
                if let notifications = note.notifications {
                    note.removeFromNotifications(notifications)
                }
            }
        }
    }
}

extension CalendarNotification {
    static func flush(_ coreDataStack: TestCoreDataStack) {
        super.flush(coreDataStack) {
            obj in
            if let notification = obj as? CalendarNotification {
                notification.note = nil
            }
        }
    }
}
