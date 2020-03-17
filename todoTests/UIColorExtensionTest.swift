//
//  todoTests.swift
//  todoTests
//
//  Created by Анатолий on 12/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

@testable import todo
import XCTest

class UIColorExtensionTest: XCTestCase {
    func testHexWhiteColor() {
        testColor(hex: 0xFFFFFF)
    }
    
    func testHexBlackColor() {
        testColor(hex: 0x000000)
    }
    
    func testHexRedColor() {
        testColor(hex: 0xFF0000)
    }
    
    func testHexGreenColor() {
        testColor(hex: 0x00FF00)
    }
    
    func testHexBlueColor() {
        testColor(hex: 0x0000FF)
    }
    
    func testHexColor() {
        testColor(hex: 0x123456)
    }
    
    func testLighterBlackColor() {
        testLighter(red: 0, green: 0, blue: 0, alpha: 1, diff: 0.1)
    }
    
    func testLighterWhiteColor() {
        testLighter(red: 1, green: 1, blue: 1, alpha: 1, diff: 0.1)
    }
    
    func testLighterColor() {
        testLighter(red: 0.1, green: 0.2, blue: 0.3, alpha: 1, diff: 0.1)
    }
    
    func testInitWhiteColor() {
        let color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let colorT = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        XCTAssert(color == colorT)
    }
    
    func testInitBlackColor() {
        let color = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let colorT = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        XCTAssert(color == colorT)
    }
    
    func testInitRedColor() {
        let color = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let colorT = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
        XCTAssert(color == colorT)
    }
    
    func testInitGreenColor() {
        let color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        let colorT = UIColor(red: 0, green: 255, blue: 0, alpha: 1)
        XCTAssert(color == colorT)
    }
    
    func testInitBlueColor() {
        let color = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        let colorT = UIColor(red: 0, green: 0, blue: 255, alpha: 1)
        XCTAssert(color == colorT)
    }
    
    private func testColor(hex: Int32) {
        let color = UIColor(hex6: hex)
        let rgb = color.rgb
        XCTAssert(hex == rgb)
    }
    
    private func testLighter(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat, diff: CGFloat) {
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        let lighterColor = UIColor(red: min(red + diff, 1.0),
                                   green: min(green + diff, 1.0),
                                   blue: min(blue + diff, 1.0),
                                   alpha: alpha)
        let lighterColorT = color.lighter(diff: diff)
        XCTAssert(lighterColor == lighterColorT)
    }
}
