//
//  NoteBackgroud+CoreDataProperties.swift
//  todo
//
//  Created by Анатолий on 06/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//
//

import CoreData
import Foundation

extension NoteBackgroud {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteBackgroud> {
        return NSFetchRequest<NoteBackgroud>(entityName: "NoteBackgroud")
    }

    @NSManaged public var notes: NSSet?
}

// MARK: Generated accessors for notes

extension NoteBackgroud {
    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)
}
