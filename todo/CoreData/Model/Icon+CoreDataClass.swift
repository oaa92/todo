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
    var fetchEquals : NSFetchRequest<Icon> {
        let fetchRequest: NSFetchRequest<Icon> = Icon.fetchRequest()
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K = %@", #keyPath(Icon.name), name ?? ""),
            NSPredicate(format: "%K = %d", #keyPath(Icon.color), color)
        ])
        fetchRequest.predicate = predicate
        return fetchRequest
    }

    func compare(with icon: Icon) -> Bool {
        if self.name == icon.name,
            self.color == icon.color {
            return true
        } else {
            return false
        }
    }
}
