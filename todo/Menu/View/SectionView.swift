//
//  SectionView.swift
//  todo
//
//  Created by Анатолий on 10/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class SectionView: UIView {
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
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
        backgroundColor = UIColor.Palette.orange_pale.get
        addSubview(label)
    }
    
    private func setupConstrains() {
        let constrains = [label.topAnchor.constraint(equalTo: topAnchor),
                          label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
                          label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                          label.bottomAnchor.constraint(equalTo: bottomAnchor)]
        NSLayoutConstraint.activate(constrains)
    }
}
