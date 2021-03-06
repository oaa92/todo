//
//  UIColor hex.swift
//  todo
//
//  Created by Анатолий on 29/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

extension UIColor {
    enum Palette {
        case grayish_orange
        case yellow_soft
        case orange_pale
        case green
        case cyan
        case blue_soft
        case blue
        case violet
        case pink
        case text
        
        var get: UIColor {
            switch self {
            case .grayish_orange:
                return UIColor(hex6: 0xF7ECE1)
            case .yellow_soft:
                return UIColor(hex6: 0xFBE6A1)
            case .orange_pale:
                return UIColor(hex6: 0xFFCAAF)
            case .green:
                return UIColor(hex6: 0xA3DBAD)
            case .cyan:
                return UIColor(hex6: 0x6ECEDA)
            case .blue_soft:
                return UIColor(hex6: 0x4997F1)
            case .blue:
                return UIColor(hex6: 0x88BADF)
            case .violet:
                return UIColor(hex6: 0xF1CBFF)
            case .pink:
                return UIColor(hex6: 0xFDC6D2)
            case .text:
                return UIColor(hex6: 0x424C55)
            }
        }
        
        enum Buttons {
            case favourites
            case edit
            case delete
            case unselected
            
            var get: UIColor {
                switch self {
                case .favourites:
                    return UIColor(hex6: 0x7D3BB8)
                case .edit:
                    return Palette.blue_soft.get
                case .delete:
                    return UIColor(hex6: 0xFB7670)
                case .unselected:
                    return .lightGray
                }
            }
        }
    }
    
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    /**
     #RRGGBB
     */
    convenience init(hex6: Int32) {
        let red = Int((hex6 & 0xFF0000) >> 16)
        let green = Int((hex6 & 0xFF00) >> 8)
        let blue = Int(hex6 & 0xFF)
        self.init(red: red, green: green, blue: blue)
    }
    
    /**
     #return RRGGBB
     */
    var rgb: Int32? {
        var redCGF: CGFloat = 0
        var greenCGF: CGFloat = 0
        var blueCGF: CGFloat = 0
        var alphaCGF: CGFloat = 0
        guard getRed(&redCGF, green: &greenCGF, blue: &blueCGF, alpha: &alphaCGF) else {
            return nil
        }
        
        let red = Int32((redCGF * 255).rounded(.toNearestOrAwayFromZero))
        let green = Int32((greenCGF * 255).rounded(.toNearestOrAwayFromZero))
        let blue = Int32((blueCGF * 255).rounded(.toNearestOrAwayFromZero))
        let result = (red << 16) + (green << 8) + blue
        return result
    }
    
    func lighter(diff: CGFloat = 0.2) -> UIColor? {
        var redCGF: CGFloat = 0
        var greenCGF: CGFloat = 0
        var blueCGF: CGFloat = 0
        var alphaCGF: CGFloat = 0
        guard getRed(&redCGF, green: &greenCGF, blue: &blueCGF, alpha: &alphaCGF) else {
            return nil
        }
        
        redCGF = min(redCGF + diff, 1.0)
        greenCGF = min(greenCGF + diff, 1.0)
        blueCGF = min(blueCGF + diff, 1.0)
        
        return UIColor(red: redCGF, green: greenCGF, blue: blueCGF, alpha: alphaCGF)
    }
}
