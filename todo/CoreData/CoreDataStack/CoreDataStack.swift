//
//  CoreDataStack.swift
//  todo
//
//  Created by Анатолий on 31/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData

class CoreDataStack {
    private let modelName: String

    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = false
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    lazy var managedContext: NSManagedObjectContext = {
        self.storeContainer.viewContext
    }()

    init(modelName: String) {
        self.modelName = modelName
    }

    func saveContext() {
        guard managedContext.hasChanges else {
            return
        }

        do {
            try managedContext.save()
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
