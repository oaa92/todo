//
//  NotificationWeekdayCell.swift
//  todo
//
//  Created by Анатолий on 26/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NotificationWeekdayCell: UICollectionViewCell, ReusableView {
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = UIColor.Palette.blue_soft.get
                label.textColor = .white
            } else {
                backgroundColor = UIColor(white: 0.9, alpha: 1.0)
                label.textColor = .gray
            }
        }
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        return label
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
        backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        layer.cornerRadius = 16
        addSubview(label)
    }
    
    private func setupConstrains() {
        let constrains = [label.centerXAnchor.constraint(equalTo: centerXAnchor),
                          label.centerYAnchor.constraint(equalTo: centerYAnchor)]
        NSLayoutConstraint.activate(constrains)
    }
}
