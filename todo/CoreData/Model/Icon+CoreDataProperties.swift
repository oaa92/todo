//
//  Icon+CoreDataProperties.swift
//  todo
//
//  Created by Анатолий on 10/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//
//

import Foundation
import CoreData


extension Icon {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Icon> {
        return NSFetchRequest<Icon>(entityName: "Icon")
    }

    @NSManaged public var color: Int32
    @NSManaged public var name: String?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for tags
extension Icon {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}
