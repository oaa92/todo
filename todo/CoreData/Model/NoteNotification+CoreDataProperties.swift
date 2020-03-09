//
//  NoteNotification+CoreDataProperties.swift
//  
//
//  Created by Анатолий on 03/03/2020.
//
//

import Foundation
import CoreData


extension NoteNotification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteNotification> {
        return NSFetchRequest<NoteNotification>(entityName: "NoteNotification")
    }

    @NSManaged public var uid: String?
    @NSManaged public var note: Note?

}
