//
//  Tag+CoreDataClass.swift
//  todo
//
//  Created by Анатолий on 06/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Tag)
public class Tag: NSManagedObject {
    var isTemp: Bool = false
    
    func delete(coreDataStack: CoreDataStack) {
        if let icon = icon {
            if icon.tags?.count == 1 {
                coreDataStack.managedContext.delete(icon)
            }
        }
        coreDataStack.managedContext.delete(self)
    }
    
    static func createTemp(name: String, icon: String, color: Int32) -> Tag {
        let tagIcon = Icon(entity: Icon.entity(), insertInto: nil)
        tagIcon.name = icon
        tagIcon.color = color
        
        let tag = Tag(entity: Tag.entity(), insertInto: nil)
        tag.name = name
        tag.icon = tagIcon
        
        tag.isTemp = true
        return tag
    }
}
