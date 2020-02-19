//
//  TagColorCell.swift
//  todo
//
//  Created by Анатолий on 16/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagColorCell: TagParamCell {
    let colorView: ColorSampleView = {
        let color = ColorSampleView()
        color.translatesAutoresizingMaskIntoConstraints = false
        return color
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstrains()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(colorView)
    }
    
    private func setupConstrains() {
        let constrains = [colorView.centerXAnchor.constraint(equalTo: centerXAnchor),
                          colorView.centerYAnchor.constraint(equalTo: centerYAnchor)]
        NSLayoutConstraint.activate(constrains)
    }
}
