//
//  Icon+CoreDataClass.swift
//  todo
//
//  Created by Анатолий on 06/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//
//

import CoreData
import Foundation

@objc(Icon)
public class Icon: NSManagedObject {
    var fetchEquals: NSFetchRequest<Icon> {
        let fetchRequest: NSFetchRequest<Icon> = Icon.fetchRequest()
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K = %@", #keyPath(Icon.name), name ?? ""),
            NSPredicate(format: "%K = %d", #keyPath(Icon.color), color)
        ])
        fetchRequest.predicate = predicate
        return fetchRequest
    }

    func searchEqualIcon(_ coreDataStack: CoreDataStack) -> Icon? {
        do {
            let fetchRequest = self.fetchEquals
            let icons = try coreDataStack.managedContext.fetch(fetchRequest)
            if icons.count > 0 {
                return icons.first
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return nil
        }
        return nil
    }

    func compare(with icon: Icon) -> Bool {
        if self.name == icon.name,
            self.color == icon.color {
            return true
        } else {
            return false
        }
    }

    func deleteIfNeeded(_ coreDataStack: CoreDataStack) {
        if let tags = tags,
            tags.count == 0 {
            coreDataStack.managedContext.delete(self)
        }
    }
}

extension Icon {
    static func createWithParams(entity: NSEntityDescription? = nil,
                                 context: NSManagedObjectContext? = nil,
                                 name: String,
                                 color: Int32) -> Icon {
        let icon = Icon(entity: entity ?? Icon.entity(), insertInto: context)
        icon.name = name
        icon.color = color
        return icon
    }
}
