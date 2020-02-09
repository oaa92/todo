//
//  GradientBackgroud+CoreDataProperties.swift
//  todo
//
//  Created by Анатолий on 06/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//
//

import Foundation
import CoreData


extension GradientBackgroud {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GradientBackgroud> {
        return NSFetchRequest<GradientBackgroud>(entityName: "GradientBackgroud")
    }

    @NSManaged public var colors: [Int32]?
    @NSManaged public var endPoint: String?
    @NSManaged public var startPoint: String?
    @NSManaged public var notes: NSSet?

}

// MARK: Generated accessors for notes
extension GradientBackgroud {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}
