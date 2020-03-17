//
//  GradientBackgroud+CoreDataClass.swift
//  todo
//
//  Created by Анатолий on 06/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//
//

import CoreData
import Foundation
import UIKit

@objc(GradientBackgroud)
public class GradientBackgroud: NSManagedObject {
    var cgColors: [CGColor] {
        get {
            return self.iColors.compactMap { UIColor(hex6: $0).cgColor }
        }
        set {
            let array = newValue.compactMap { UIColor(cgColor: $0).rgb }
            self.iColors = array
        }
    }

    var iColors: [Int32] {
        get {
            if let colorsString = colors,
                let data = colorsString.data(using: .utf8),
                let array = try? JSONDecoder().decode([Int32].self, from: data),
                array.count > 1 {
                return array
            } else {
                return []
            }
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                let colorString = String(bytes: data, encoding: .utf8)
                colors = colorString
            }
        }
    }

    var fetchEquals: NSFetchRequest<GradientBackgroud> {
        let fetchRequest: NSFetchRequest<GradientBackgroud> = GradientBackgroud.fetchRequest()
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K = %@", #keyPath(GradientBackgroud.startPoint), startPoint ?? ""),
            NSPredicate(format: "%K = %@", #keyPath(GradientBackgroud.endPoint), endPoint ?? ""),
            NSPredicate(format: "%K = %@", #keyPath(GradientBackgroud.colors), colors ?? "")
        ])
        fetchRequest.predicate = predicate
        return fetchRequest
    }

    func searchEqualBackground(_ coreDataStack: CoreDataStack) -> GradientBackgroud? {
        do {
            let fetchRequest = self.fetchEquals
            let backgrounds = try coreDataStack.managedContext.fetch(fetchRequest)
            if backgrounds.count > 0 {
                return backgrounds.first
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return nil
        }
        return nil
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

    @discardableResult func loadToLayer(layer: CAGradientLayer) -> Bool {
        let cgColors = self.cgColors
        guard let startPointStr = startPoint,
            let endPointStr = endPoint,
            cgColors.count > 1 else {
            return false
        }
        let startPoint = NSCoder.cgPoint(for: startPointStr)
        let endPoint = NSCoder.cgPoint(for: endPointStr)
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        layer.colors = cgColors
        return true
    }

    func deleteIfNeeded(_ coreDataStack: CoreDataStack) {
        if let notes = notes,
            notes.count == 0 {
            coreDataStack.managedContext.delete(self)
        }
    }
}

extension GradientBackgroud {
    static func createFromLayer(entity: NSEntityDescription? = nil,
                                context: NSManagedObjectContext? = nil,
                                layer: CAGradientLayer) -> GradientBackgroud {
        let background = GradientBackgroud(entity: entity ?? GradientBackgroud.entity(), insertInto: context)
        let startPointStr = NSCoder.string(for: layer.startPoint)
        let endPointStr = NSCoder.string(for: layer.endPoint)
        background.startPoint = startPointStr
        background.endPoint = endPointStr
        background.cgColors = layer.colors as? [CGColor] ?? [UIColor.Palette.yellow_soft.get.cgColor,
                                                             UIColor.Palette.orange_pale.get.cgColor]
        return background
    }

    static func createWithParams(entity: NSEntityDescription? = nil,
                                 context: NSManagedObjectContext? = nil,
                                 start: CGPoint,
                                 end: CGPoint,
                                 colors: [Int32]) -> GradientBackgroud {
        let background = GradientBackgroud(entity: entity ?? GradientBackgroud.entity(), insertInto: context)
        background.startPoint = NSCoder.string(for: start)
        background.endPoint = NSCoder.string(for: end)
        background.iColors = colors
        return background
    }
}
