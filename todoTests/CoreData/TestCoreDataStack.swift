//
//  TestCoreDataStack.swift
//  todoTests
//
//  Created by Анатолий on 14/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
@testable import todo

class TestCoreDataStack: CoreDataStack {
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))])!
        return managedObjectModel
    }()

    lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PersistentTodo",
                                              managedObjectModel: self.managedObjectModel)
        let description = container.persistentStoreDescriptions.first
        description?.type = NSInMemoryStoreType
        description?.shouldAddStoreAsynchronously = false
        container.loadPersistentStores { description, error in
            precondition(description.type == NSInMemoryStoreType)
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    init() {
        super.init(modelName: "todo")
        managedContext = storeContainer.viewContext
    }
}
