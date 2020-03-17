//
//  CDTests.swift
//  todoTests
//
//  Created by Анатолий on 15/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
@testable import todo
import XCTest

class CDTests: XCTestCase {
    var coreDataStack: TestCoreDataStack!
    
    override func setUp() {
        super.setUp()
        coreDataStack = TestCoreDataStack()
    }
    
    override func tearDown() {
        coreDataStack.saveContext()
        coreDataStack = nil
        super.tearDown()
    }
    
    func createIcon(context: NSManagedObjectContext, name: String = "icon") -> Icon {
        let icon = Icon(context: context)
        icon.name = name
        icon.color = 0x123456
        return icon
    }
    
    func createGradientBackground(context: NSManagedObjectContext,
                                  start: CGPoint = CGPoint(x: 0, y: 1),
                                  end: CGPoint = CGPoint(x: 1, y: 0),
                                  colors: [Int32] = [0x000000, 0xffffff]) -> GradientBackgroud {
        let background = GradientBackgroud(context: context)
        background.startPoint = NSCoder.string(for: start)
        background.endPoint = NSCoder.string(for: end)
        background.iColors = colors
        return background
    }
    
    func createNotification(context: NSManagedObjectContext,
                            date: Date = Date(timeIntervalSince1970: 0),
                            period: PeriodType = .none) -> CalendarNotification {
        let data = try! JSONEncoder().encode(period)
        let notification = CalendarNotification(context: coreDataStack.managedContext)
        notification.uid = "2020FFAA-C36C-495A-93FC-0C247A3E6E5F"
        notification.date = date
        notification.period = data
        return notification
    }
    
    func createNote(context: NSManagedObjectContext) -> Note {
        let note = Note(context: context)
        note.createdAt = Date(timeIntervalSince1970: 0)
        note.uid = UUID(uuidString: "1010EEEE-C36C-495A-93FC-0C247A3E6E5F")
        note.title = "title"
        note.text = "text"
        note.background = createGradientBackground(context: context)
        return note
    }
}
