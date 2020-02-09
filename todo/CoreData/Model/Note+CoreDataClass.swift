//
//  Note+CoreDataClass.swift
//  todo
//
//  Created by Анатолий on 31/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {
    
    override public func awakeFromInsert() {
        setPrimitiveValue(UUID(), forKey: #keyPath(Note.uid))
        setPrimitiveValue(Date(), forKey: #keyPath(Note.createdAt))
    }
    
    override public func willSave() {
        if let updated = updatedAt {
            if updated.timeIntervalSince(Date()) > 10.0 {
                self.updatedAt = Date()
            }
        } else {
            self.updatedAt = Date()
        }
    }
}
