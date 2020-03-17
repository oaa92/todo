//
//  NoteNotification+CoreDataClass.swift
//
//
//  Created by Анатолий on 29/02/2020.
//
//

import CoreData
import Foundation

@objc(NoteNotification)
public class NoteNotification: NSManagedObject {
    func delete(_ coreDataStack: CoreDataStack) {
        coreDataStack.managedContext.delete(self)
    }
}
