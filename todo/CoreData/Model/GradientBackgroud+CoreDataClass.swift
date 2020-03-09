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
            if let colorsString = colors,
                let data = colorsString.data(using: .utf8),
                let array = try? JSONDecoder().decode([Int32].self, from: data),
                array.count > 1 {
                return array.compactMap { UIColor(hex6: $0).cgColor }
            } else {
                return []
            }
        }
        set {
            let array = newValue.compactMap { UIColor(cgColor: $0).rgb }
            if let data = try? JSONEncoder().encode(array) {
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
    
    static func createFromLayer(layer: CAGradientLayer) -> GradientBackgroud {
        let background = GradientBackgroud(entity: GradientBackgroud.entity(), insertInto: nil)
        let startPointStr = NSCoder.string(for: layer.startPoint)
        let endPointStr = NSCoder.string(for: layer.endPoint)
        background.startPoint = startPointStr
        background.endPoint = endPointStr
        background.cgColors = layer.colors as? [CGColor] ?? [UIColor.Palette.yellow_soft.get.cgColor,
                                                             UIColor.Palette.orange_pale.get.cgColor]
        return background
    }
}
