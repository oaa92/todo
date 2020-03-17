//
//  CDTagTests.swift
//  todoTests
//
//  Created by Анатолий on 14/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
@testable import todo
import XCTest

class CDTagTests: CDTests {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        Icon.flush(coreDataStack)
        Tag.flush(coreDataStack)
        super.tearDown()
    }
    
    func testCreateTag() {
        let tag = Tag(context: coreDataStack.managedContext)
        XCTAssertFalse(tag.isTemp)
    }
    
    func testCreateTempTag() {
        let name = "tagName"
        let icon = createIcon(context: coreDataStack.managedContext)
        let tag = Tag.createWithParams(entity: NSEntityDescription.entity(forEntityName: Tag.description(),
                                                                          in: coreDataStack.managedContext),
                                       context: coreDataStack.managedContext,
                                       name: name,
                                       icon: icon,
                                       isTemp: true)
        XCTAssertTrue(tag.isTemp)
        XCTAssert(tag.name == name)
        XCTAssert(tag.icon!.name == icon.name!)
        XCTAssert(tag.icon!.color == icon.color)
    }
    
    func testSetIcon() {
        let icon = createIcon(context: coreDataStack.managedContext)
        let tag = Tag(context: coreDataStack.managedContext)
        tag.setIcon(coreDataStack, icon: icon)
        XCTAssert(tag.icon == icon)
    }
    
    func testSetIconNil() {
        let icon = createIcon(context: coreDataStack.managedContext)
        let tag = Tag(context: coreDataStack.managedContext)
        tag.icon = icon
        XCTAssertNotNil(tag.icon)
        tag.setIcon(coreDataStack, icon: nil)
        XCTAssertNil(tag.icon)
        XCTAssertTrue(icon.isDeleted)
    }
    
    func testSetIconComparing() {
        let context = coreDataStack.managedContext
        let icon1 = createIcon(context: context)
        let tag = Tag(context: context)
        tag.setIcon(coreDataStack, icon: icon1)
        let icon2 = createIcon(context: context)
        tag.setIcon(coreDataStack, icon: icon2)
        XCTAssert(tag.icon == icon1)
    }
    
    func testDeleteWithIcon() {
        let context = coreDataStack.managedContext
        let icon = createIcon(context: context)
        let tag = Tag(context: context)
        tag.icon = icon
        tag.delete(coreDataStack: coreDataStack)
        XCTAssertTrue(tag.isDeleted)
        XCTAssertTrue(icon.isDeleted)
    }
}
