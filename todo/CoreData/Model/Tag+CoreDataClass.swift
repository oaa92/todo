//
//  Tag+CoreDataClass.swift
//  todo
//
//  Created by Анатолий on 06/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//
//

import CoreData
import Foundation

@objc(Tag)
public class Tag: NSManagedObject {
    var isTemp: Bool = false

    private func deleteIconIfNeeded(_ coreDataStack: CoreDataStack) {
        guard let icon = icon else {
            return
        }
        self.icon = nil
        icon.deleteIfNeeded(coreDataStack)
    }

    func delete(coreDataStack: CoreDataStack) {
        deleteIconIfNeeded(coreDataStack)
        coreDataStack.managedContext.delete(self)
    }

    func setIcon(_ coreDataStack: CoreDataStack, icon newIcon: Icon?) {
        guard let newIcon = newIcon else {
            deleteIconIfNeeded(coreDataStack)
            return
        }
        if let icon = icon,
            newIcon.compare(with: icon) {
            return
        }

        let setIcon: Icon
        if let equalIcon = newIcon.searchEqualIcon(coreDataStack) {
            setIcon = equalIcon
        } else {
            coreDataStack.managedContext.insert(newIcon)
            setIcon = newIcon
        }
        deleteIconIfNeeded(coreDataStack)
        icon = setIcon
    }
}

extension Tag {
    static func createWithParams(entity: NSEntityDescription? = nil,
                                 context: NSManagedObjectContext? = nil,
                                 name: String,
                                 icon: Icon? = nil,
                                 isTemp: Bool = false) -> Tag {
        let tag = Tag(entity: entity ?? Tag.entity(), insertInto: context)
        tag.name = name
        tag.icon = icon
        tag.isTemp = isTemp
        return tag
    }
}
