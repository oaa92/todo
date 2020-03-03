//
//  todoTests.swift
//  todoTests
//
//  Created by Анатолий on 28/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

@testable import todo
import XCTest

class todoTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
/*
    func testNotificationEveryDay() {
        let authorizationExpectation = self.expectation(description: "authorization")
        notifications.authorization() {
            _, _ in
            authorizationExpectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        
        let id = getID()
        var date = createDate(from: "02/01/2020 13:30:30")
        let calendar = Calendar.autoupdatingCurrent
        let dateComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: date)
        var components = DateComponents()
        components.hour = dateComponents.hour
        components.minute = dateComponents.minute
        let createExpectation = self.expectation(description: "create")
        self.notifications.create(identifier: id, body: "", dateInfo: components, repeats: true, completion: {
            _ in
            createExpectation.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
        
        let notificationsExpectation = self.expectation(description: "notifications")
        var notifications: [UNNotificationRequest] = []
        self.notifications.center.getPendingNotificationRequests {
            arr in
            notifications = arr
            notificationsExpectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        
        let notification = notifications.first(where: { $0.identifier == id })
        let trigger = notification!.trigger as! UNCalendarNotificationTrigger
        let nextDate = trigger.nextTriggerDate()
        let nextDateComponents = calendar.dateComponents([.day, .month, .year], from: nextDate!)

        date.addTimeInterval(3600 * 24)
        let nextDayComponents = calendar.dateComponents([.day, .month, .year], from: date)
        XCTAssert(nextDateComponents == nextDayComponents)
    }

    private func getID() -> String {
        let id = UUID().uuidString
        ids.append(id)
        return id
    }

    private func createDate(from: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 7 * 3600)
        let date = formatter.date(from: from)!
        return date
    }
 */
}
