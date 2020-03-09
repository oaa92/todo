//
//  GradientBackgroundMigrationPolicy_v1_v2.swift
//  todo
//
//  Created by Анатолий on 09/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
import UIKit

let errorDomain = "Migration"

class GradientBackgroundMigrationPolicy_v1_v2: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject,
                                             in mapping: NSEntityMapping,
                                             manager: NSMigrationManager) throws {
        let description = NSEntityDescription.entity(forEntityName: "GradientBackgroud", in: manager.destinationContext)
        let newGradientBackgroud = GradientBackgroud(entity: description!, insertInto: manager.destinationContext)

        func traversePropertyMappings(block: (NSPropertyMapping, String) -> ()) throws {
            if let attributeMappings = mapping.attributeMappings {
                for propertyMapping in attributeMappings {
                    if let destinationName = propertyMapping.name {
                        block(propertyMapping, destinationName)
                    } else {
                        let message = "Attribute destination not configured properly"
                        let userInfo = [NSLocalizedFailureReasonErrorKey: message]
                        throw NSError(domain: errorDomain, code: 0, userInfo: userInfo)
                    }
                }
            } else {
                let message = "No Attribute Mappings found!"
                let userInfo = [NSLocalizedFailureReasonErrorKey: message]
                throw NSError(domain: errorDomain, code: 0, userInfo: userInfo)
            }
        }

        try traversePropertyMappings {
            propertyMapping, destinationName in
            if let valueExpression = propertyMapping.valueExpression {
                let context: NSMutableDictionary = ["source": sInstance]
                guard let destinationValue = valueExpression.expressionValue(with: sInstance, context: context) else {
                    return
                }
                newGradientBackgroud.setValue(destinationValue, forKey: destinationName)
            }
        }

        if let colors = sInstance.value(forKey: "colors") as? [Int32],
            let data = try? JSONEncoder().encode(colors),
            let json = String(bytes: data, encoding: .utf8) {
            newGradientBackgroud.setValue(json, forKey: "colors")
        } else {
            newGradientBackgroud.setValue("[\(0x00FF00),\(0xFF0000)]", forKey: "colors")
        }
        manager.associate(sourceInstance: sInstance, withDestinationInstance: newGradientBackgroud, for: mapping)
    }
}
