//
//  GradientBackgroud+CoreDataClass.swift
//  todo
//
//  Created by Анатолий on 06/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(GradientBackgroud)
public class GradientBackgroud: NSManagedObject {
    var cgColors: [CGColor] {
        get {
            guard let colors = colors else {
                return []
            }
            return colors.compactMap { UIColor(hex6: $0).cgColor }
        }
        set {
            colors = newValue.compactMap{ UIColor(cgColor: $0).rgb }
        }
    }
    
    var fetchEquals : NSFetchRequest<GradientBackgroud> {
        let fetchRequest: NSFetchRequest<GradientBackgroud> = GradientBackgroud.fetchRequest()
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K = %@", #keyPath(GradientBackgroud.startPoint), startPoint ?? ""),
            NSPredicate(format: "%K = %@", #keyPath(GradientBackgroud.endPoint), endPoint ?? ""),
            NSPredicate(format: "%K = %@", #keyPath(GradientBackgroud.endPoint), colors ?? [])
        ])
        fetchRequest.predicate = predicate
        return fetchRequest
    }

    func compare(with gradient: GradientBackgroud) -> Bool {
        if self.startPoint == gradient.startPoint,
            self.endPoint == gradient.endPoint,
            self.colors == gradient.colors {
            return true
        } else {
            return false
        }
    }
}
