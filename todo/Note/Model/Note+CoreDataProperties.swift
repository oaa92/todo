//
//  Note+CoreDataProperties.swift
//  todo
//
//  Created by Анатолий on 02/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var uid: UUID?
    @NSManaged public var updatedAt: Date?

}
