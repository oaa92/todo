//
//  CDGradientBackgroudTests.swift
//  todoTests
//
//  Created by Анатолий on 15/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
@testable import todo
import XCTest

class CDGradientBackgroudTests: CDTests {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        Note.flush(coreDataStack)
        GradientBackgroud.flush(coreDataStack)
        super.tearDown()
    }

    func testCreateGradientBackgroud() {
        let start = CGPoint(x: 0, y: 1)
        let end = CGPoint(x: 1, y: 0)
        let startStr = NSCoder.string(for: start)
        let endStr = NSCoder.string(for: end)
        let colors: [Int32] = [0x000000, 0xFFFFFF]
        let data = try! JSONEncoder().encode(colors)
        let colorsStr = String(bytes: data, encoding: .utf8)
        let background = GradientBackgroud.createWithParams(entity: NSEntityDescription.entity(forEntityName: GradientBackgroud.description(),
                                                                                               in: coreDataStack.managedContext),
                                                            context: coreDataStack.managedContext,
                                                            start: start,
                                                            end: end,
                                                            colors: colors)
        XCTAssert(background.startPoint == startStr)
        XCTAssert(background.endPoint == endStr)
        XCTAssert(background.colors == colorsStr)
    }

    func testCreateGradientBackgroudFromLayer() {
        let start = CGPoint(x: 0, y: 1)
        let end = CGPoint(x: 1, y: 0)
        let startStr = NSCoder.string(for: start)
        let endStr = NSCoder.string(for: end)
        let colors: [Int32] = [0x000000, 0xFFFFFF]
        let data = try! JSONEncoder().encode(colors)
        let colorsStr = String(bytes: data, encoding: .utf8)
        let cgColors = [UIColor.black.cgColor, UIColor.white.cgColor]
        let layer = CAGradientLayer()
        layer.startPoint = start
        layer.endPoint = end
        layer.colors = cgColors
        let background = GradientBackgroud.createFromLayer(entity: NSEntityDescription.entity(forEntityName: GradientBackgroud.description(),
                                                                                              in: coreDataStack.managedContext),
                                                           context: coreDataStack.managedContext,
                                                           layer: layer)
        XCTAssert(background.startPoint == startStr)
        XCTAssert(background.endPoint == endStr)
        XCTAssert(background.colors == colorsStr)
    }

    func testLoadToLayer() {
        let start = CGPoint(x: 0, y: 1)
        let end = CGPoint(x: 1, y: 0)
        let colors: [Int32] = [0x000000, 0xFFFFFF]
        let cgColors = [UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor,
                        UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor]
        let background = createGradientBackground(context: coreDataStack.managedContext,
                                                  start: start,
                                                  end: end,
                                                  colors: colors)
        let layer = CAGradientLayer()
        background.loadToLayer(layer: layer)
        let layerColors = layer.colors as! [CGColor]
        XCTAssert(layer.startPoint == start)
        XCTAssert(layer.endPoint == end)
        XCTAssert(layerColors == cgColors)
    }

    func testGetCGColors() {
        let colors: [Int32] = [0x000000, 0xFFFFFF]
        let cgColors = [UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor,
                        UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor]
        let background = createGradientBackground(context: coreDataStack.managedContext,
                                                  colors: colors)
        XCTAssert(background.cgColors == cgColors)
    }

    func testSetCGColors() {
        let colors: [Int32] = [0x000000, 0xFFFFFF]
        let data = try! JSONEncoder().encode(colors)
        let colorsStr = String(bytes: data, encoding: .utf8)
        let cgColors = [UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor,
                        UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor]
        let background = GradientBackgroud(context: coreDataStack.managedContext)
        background.cgColors = cgColors
        XCTAssert(background.colors! == colorsStr)
    }

    func testSetIColor() {
        let colors: [Int32] = [0x000000, 0xFFFFFF]
        let data = try! JSONEncoder().encode(colors)
        let colorsStr = String(bytes: data, encoding: .utf8)
        let background = GradientBackgroud(context: coreDataStack.managedContext)
        background.iColors = colors
        XCTAssert(background.colors! == colorsStr)
    }

    func testGetIColor() {
        let colors: [Int32] = [0x000000, 0xFFFFFF]
        let data = try! JSONEncoder().encode(colors)
        let colorsStr = String(bytes: data, encoding: .utf8)
        let background = GradientBackgroud(context: coreDataStack.managedContext)
        background.colors = colorsStr
        let iColors = background.iColors
        XCTAssert(iColors == colors)
    }

    func testFetchEquals() {
        let background1 = createGradientBackground(context: coreDataStack.managedContext)
        let background2 = createGradientBackground(context: coreDataStack.managedContext)
        let background3 = createGradientBackground(context: coreDataStack.managedContext)
        background3.startPoint = UUID().uuidString
        let background4 = createGradientBackground(context: coreDataStack.managedContext)
        background4.endPoint = UUID().uuidString
        let background5 = createGradientBackground(context: coreDataStack.managedContext)
        let fetchRequest = background1.fetchEquals
        let backgrounds = try! coreDataStack.managedContext.fetch(fetchRequest)
        XCTAssert(backgrounds.count == 3)
        XCTAssert(backgrounds.contains(background1))
        XCTAssert(backgrounds.contains(background2))
        XCTAssert(backgrounds.contains(background5))
    }

    func testSearchEqualBackground() {
        let background = createGradientBackground(context: coreDataStack.managedContext)
        let findBackground = background.searchEqualBackground(coreDataStack)
        XCTAssertNotNil(findBackground)
        XCTAssert(findBackground == background)
    }

    func testComparing() {
        let background1 = createGradientBackground(context: coreDataStack.managedContext)
        let background2 = createGradientBackground(context: coreDataStack.managedContext)
        XCTAssertTrue(background1.compare(with: background2))
        background1.startPoint = UUID().uuidString
        XCTAssertFalse(background1.compare(with: background2))
    }

    func testDelete() {
        let background = createGradientBackground(context: coreDataStack.managedContext)
        background.deleteIfNeeded(coreDataStack)
        XCTAssertTrue(background.isDeleted)
    }

    func testDeleteUsableBackground() {
        let background = createGradientBackground(context: coreDataStack.managedContext)
        let note = createNote(context: coreDataStack.managedContext)
        note.background = background
        background.deleteIfNeeded(coreDataStack)
        XCTAssertFalse(background.isDeleted)
    }
}
