//
//  CDNoteTests.swift
//  todoTests
//
//  Created by Анатолий on 16/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
@testable import todo
import XCTest

class CDNoteTests: CDTests {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        Note.flush(coreDataStack)
        GradientBackgroud.flush(coreDataStack)
        CalendarNotification.flush(coreDataStack)
        Icon.flush(coreDataStack)
        Tag.flush(coreDataStack)
        super.tearDown()
    }
    
    func testDefaultValues() {
        let note = Note(context: coreDataStack.managedContext)
        XCTAssertNotNil(note.uid)
        XCTAssertNotNil(note.createdAt)
        let diff = Date().distance(to: note.createdAt!)
        XCTAssert(diff < 60)
    }
    
    func testSaveValues() {
        let note = Note(context: coreDataStack.managedContext)
        note.background = createGradientBackground(context: coreDataStack.managedContext)
        coreDataStack.saveContext()
        XCTAssertNotNil(note.updatedAt)
    }
    
    func testDelete() {
        let note = Note(context: coreDataStack.managedContext)
        let background = createGradientBackground(context: coreDataStack.managedContext)
        note.background = background
        note.delete(coreDataStack: coreDataStack)
        XCTAssertTrue(background.isDeleted)
        XCTAssertTrue(note.isDeleted)
    }
    
    func testMoveToTrash() {
        let note = createNote(context: coreDataStack.managedContext)
        let notification = createNotification(context: coreDataStack.managedContext)
        let id = notification.uid!
        note.addToNotifications(notification)
        
        let ids = note.moveToTrash(coreDataStack)
        coreDataStack.saveContext()
        
        XCTAssert(ids == [id])
        XCTAssertNotNil(note.deletedAt)
        XCTAssert(note.notifications!.count == 0)
        XCTAssertFalse(note.isDeleted)
    }
    
    func testSetBackgroundComparing() {
        let note = Note(context: coreDataStack.managedContext)
        let background1 = createGradientBackground(context: coreDataStack.managedContext)
        let background2 = createGradientBackground(context: coreDataStack.managedContext)
        note.background = background1
        
        note.setBackground(coreDataStack, background: background2)
        XCTAssert(note.background == background1)
    }
    
    func testSetBackground() {
        let note = createNote(context: coreDataStack.managedContext)
        let background1 = createGradientBackground(context: coreDataStack.managedContext, start: CGPoint(x: 0, y: 1))
        let background2 = createGradientBackground(context: coreDataStack.managedContext, start: CGPoint(x: 0.5, y: 0.5))
        note.background = background1
        note.setBackground(coreDataStack, background: background2)
        XCTAssert(note.background == background2)
        XCTAssertTrue(background1.isDeleted)
    }
    
    func testSetTags() {
        let createTagsSet = {
            () -> Set<Tag> in
            var tags: Set<Tag> = []
            for _ in 0..<5 {
                let tag = Tag(context: self.coreDataStack.managedContext)
                tag.name = UUID().uuidString
                tags.insert(tag)
            }
            return tags
        }
        
        let note = Note(context: coreDataStack.managedContext)
        let tags1 = createTagsSet()
        var tags2 = createTagsSet()
        tags2.insert(tags1.first!)
        
        note.setTags(coreDataStack, tags: tags1)
        XCTAssert(note.tags as! Set < Tag> == tags1)
        
        note.setTags(coreDataStack, tags: tags2)
        XCTAssert(note.tags as! Set < Tag> == tags2)
    }
    
    func testSetNotifications() {
        var interval: TimeInterval = 0
        let createNotificationsSet = {
            () -> Set<CalendarNotification> in
            var notifications: Set<CalendarNotification> = []
            for _ in 0..<5 {
                let notification = CalendarNotification(context: self.coreDataStack.managedContext)
                notification.uid = UUID().uuidString
                notification.date = Date(timeIntervalSince1970: interval)
                interval += 60
                notifications.insert(notification)
            }
            return notifications
        }
        
        let note = createNote(context: coreDataStack.managedContext)
        let notifications1 = createNotificationsSet()
        var notifications2 = createNotificationsSet()
        let jointNotification = notifications1.first!
        notifications2.insert(jointNotification)
        
        let (add1, del1) = note.setNotifications(coreDataStack, notifications: notifications1)
        XCTAssert(note.notifications as! Set < CalendarNotification> == notifications1)
        XCTAssert(Set(add1) == notifications1)
        XCTAssert(del1 == [])
        
        let (add2, del2) = note.setNotifications(coreDataStack, notifications: notifications2)
        let add2Sample = notifications2.subtracting([jointNotification])
        let del2NotificationsSample = notifications1.subtracting([jointNotification])
        let del2Sample = del2NotificationsSample.compactMap { $0.uid }
        XCTAssert(Set(add2) == add2Sample)
        XCTAssert(del2.sorted() == del2Sample.sorted())
    }
}
