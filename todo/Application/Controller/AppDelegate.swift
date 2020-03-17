//
//  AppDelegate.swift
//  todo
//
//  Created by Анатолий on 28/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var locale: Locale!
    lazy var coreDataStack = CoreDataStack(modelName: "todo")
    lazy var notificationsManager = NotificationsManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().barTintColor = UIColor.Palette.grayish_orange.get
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        locale = Locale.autoupdatingCurrent

        notificationsManager.locale = locale
        notificationsManager.coreDataStack = coreDataStack
        notificationsManager.window = window

        let rootController = NotesTableController()
        rootController.locale = locale
        rootController.coreDataStack = coreDataStack
        rootController.notificationsManager = notificationsManager
        window?.rootViewController = UINavigationController(rootViewController: rootController)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
}
