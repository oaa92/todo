//
//  TagParamCell.swift
//  todo
//
//  Created by Анатолий on 16/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagParamCell: UICollectionViewCell, ReusableView {
    let borderColor = UIColor.clear.cgColor
    var selectedColor = UIColor.Palette.blue_soft.get.cgColor
    
    override var isSelected: Bool {
        didSet {
            let toColor = isSelected ? selectedColor : UIColor.clear.cgColor
            layer.borderColor = toColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        layer.borderColor = borderColor
        layer.cornerRadius = 25
        layer.borderWidth = 5
        clipsToBounds = true
    }
}
