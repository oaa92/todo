//
//  ColorSampleView.swift
//  todo
//
//  Created by Анатолий on 16/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class ColorSampleView: UIView {
    var borderColor: UIColor = .clear {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var color: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var width: CGFloat = 50
    var height: CGFloat = 50
    var radius: CGFloat = 25
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: height)
    }
    
    init() {
        super.init(frame: CGRect.zero)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    fileprivate func configure() {
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawCircle()
    }
    
    func drawCircle() {
        borderColor.setStroke()
        color.setFill()
        
        let center = CGPoint(x: width / 2, y: height / 2)
        let bezierPath = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: 0,
                                      endAngle: CGFloat.pi * 2,
                                      clockwise: true)
        bezierPath.close()
        bezierPath.fill()
        bezierPath.stroke()
    }
}
