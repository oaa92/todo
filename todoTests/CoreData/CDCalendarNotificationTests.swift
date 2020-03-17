//
//  CDCalendarNotificationTests.swift
//  todoTests
//
//  Created by Анатолий on 16/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
@testable import todo
import XCTest

class CDCalendarNotificationTests: CDTests {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        CalendarNotification.flush(coreDataStack)
        super.tearDown()
    }

    func testCreateNotification() {
        let period = PeriodType.none
        let data = try! JSONEncoder().encode(period)
        let date = Date(timeIntervalSince1970: 0)
        let entity = NSEntityDescription.entity(forEntityName: CalendarNotification.description(),
                                                in: coreDataStack.managedContext)
        let notification = CalendarNotification.createWithParams(entity: entity,
                                                                 context: coreDataStack.managedContext,
                                                                 date: date,
                                                                 period: period)
        XCTAssert(notification?.uid ?? "" != "")
        XCTAssert(notification!.date == date)
        XCTAssert(notification!.period == data)
    }

    func testSubtractingEquals() {
        let notification1 = createNotification(context: coreDataStack.managedContext)
        let notification2 = createNotification(context: coreDataStack.managedContext,
                                               date: Date().addingTimeInterval(3600))
        let a = [notification1, notification2]
        let b = a
        let result1 = CalendarNotification.subtracting(a: a, b: b)
        XCTAssert(result1 == [])
        let result2 = CalendarNotification.subtracting(a: b, b: a)
        XCTAssert(result2 == [])
    }

    func testSubtractingDifferent() {
        let notification1 = createNotification(context: coreDataStack.managedContext)
        let notification2 = createNotification(context: coreDataStack.managedContext,
                                               date: Date().addingTimeInterval(3600))
        let a = [notification1]
        let b = [notification2]
        let result1 = CalendarNotification.subtracting(a: a, b: b)
        XCTAssert(result1 == a)
        let result2 = CalendarNotification.subtracting(a: b, b: a)
        XCTAssert(result2 == b)
    }

    func testSubtracting() {
        let notification1 = createNotification(context: coreDataStack.managedContext)
        let notification2 = createNotification(context: coreDataStack.managedContext,
                                               date: Date().addingTimeInterval(3600))
        let notification3 = createNotification(context: coreDataStack.managedContext,
                                               date: Date().addingTimeInterval(7200))
        let a = [notification1, notification3]
        let b = [notification2, notification3]
        let result1 = CalendarNotification.subtracting(a: a, b: b)
        XCTAssert(result1 == [notification1])
        let result2 = CalendarNotification.subtracting(a: b, b: a)
        XCTAssert(result2 == [notification2])
    }

    func testGetPeriod() {
        let periods: [PeriodType] = [.none,
                                     .daily,
                                     .weekly(weekdays: nil),
                                     .weekly(weekdays: [0, 6]),
                                     .monthly,
                                     .annually]
        for period in periods {
            let notification = createNotification(context: coreDataStack.managedContext)
            let data = try! JSONEncoder().encode(period)
            notification.period = data
            XCTAssert(notification.getPeriod! == period, "Period: \(period.name)")
        }
    }

    func testComparing() {
        let notification1 = createNotification(context: coreDataStack.managedContext)
        let notification2 = createNotification(context: coreDataStack.managedContext)
        XCTAssertTrue(notification1.compare(with: notification2))
        notification1.date = Date().addingTimeInterval(3600)
        XCTAssertFalse(notification1.compare(with: notification2))
    }

    func testDelete() {
        let notification = createNotification(context: coreDataStack.managedContext)
        notification.delete(coreDataStack)
        XCTAssertTrue(notification.isDeleted)
    }
}
