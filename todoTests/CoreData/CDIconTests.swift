//
//  CDIconTests.swift
//  todoTests
//
//  Created by Анатолий on 15/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
@testable import todo
import XCTest

class CDIconTests: CDTests {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        Icon.flush(coreDataStack)
        Tag.flush(coreDataStack)
        super.tearDown()
    }

    func testCreateIcon() {
        let iconName = "tagIconName"
        let color: Int32 = 0x123456
        let icon = Icon.createWithParams(entity: NSEntityDescription.entity(forEntityName: Icon.description(),
                                                                            in: coreDataStack.managedContext),
                                         context: coreDataStack.managedContext,
                                         name: iconName,
                                         color: color)
        XCTAssert(icon.name == iconName)
        XCTAssert(icon.color == color)
    }

    func testFetchEquals() {
        let icon1 = createIcon(context: coreDataStack.managedContext)
        let icon2 = createIcon(context: coreDataStack.managedContext)
        let icon3 = createIcon(context: coreDataStack.managedContext)
        icon3.name = UUID().uuidString
        let icon4 = createIcon(context: coreDataStack.managedContext)
        icon4.name = UUID().uuidString
        let icon5 = createIcon(context: coreDataStack.managedContext)
        let fetchRequest = icon1.fetchEquals
        let icons = try! coreDataStack.managedContext.fetch(fetchRequest)
        XCTAssert(icons.count == 3)
        XCTAssert(icons.contains(icon1))
        XCTAssert(icons.contains(icon2))
        XCTAssert(icons.contains(icon5))
    }

    func testSearchEqual() {
        let icon = createIcon(context: coreDataStack.managedContext)
        let findIcon = icon.searchEqualIcon(coreDataStack)
        XCTAssertNotNil(findIcon)
        XCTAssert(findIcon == icon)
    }

    func testComparing() {
        let icon1 = createIcon(context: coreDataStack.managedContext)
        let icon2 = createIcon(context: coreDataStack.managedContext)
        XCTAssertTrue(icon1.compare(with: icon2))
        icon2.name = UUID().uuidString
        XCTAssertFalse(icon1.compare(with: icon2))
    }

    func testDelete() {
        let icon = createIcon(context: coreDataStack.managedContext)
        icon.deleteIfNeeded(coreDataStack)
        XCTAssertTrue(icon.isDeleted)
    }

    func testDeleteUsableIcon() {
        let tag = Tag(context: coreDataStack.managedContext)
        let icon = createIcon(context: coreDataStack.managedContext)
        tag.icon = icon
        icon.deleteIfNeeded(coreDataStack)
        XCTAssertFalse(icon.isDeleted)
    }
}
