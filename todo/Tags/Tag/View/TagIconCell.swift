//
//  TagIconCell.swift
//  todo
//
//  Created by Анатолий on 16/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagIconCell: TagParamCell {
    let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        addSubview(iconView)
    }

    private func setupConstrains() {
        let constrains = [iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
                          iconView.centerYAnchor.constraint(equalTo: centerYAnchor)]
        NSLayoutConstraint.activate(constrains)
    }
}
