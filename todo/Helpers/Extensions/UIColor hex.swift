//
//  UIColor.swift
//  todo
//
//  Created by Анатолий on 29/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
        
    /**
    #RRGGBB
    */
    public convenience init(hex6: Int) {
        let red = Int((hex6 & 0xFF0000) >> 16)
        let green = Int((hex6 & 0xFF00) >> 8)
        let blue = Int(hex6 & 0xFF)
        self.init(red: red, green: green, blue: blue)
    }
    
    var rgb: Int? {
        var r : CGFloat = 0
        var g : CGFloat = 0
        var b : CGFloat = 0
        var a : CGFloat = 0
        
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }
        
        let red = Int((r * 255).rounded(.toNearestOrAwayFromZero))
        let green = Int((r * 255).rounded(.toNearestOrAwayFromZero))
        let blue = Int((r * 255).rounded(.toNearestOrAwayFromZero))
        return (red << 16) | (green << 8) | blue
    }
}
