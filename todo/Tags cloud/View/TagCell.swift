//
//  TagCell.swift
//  todo
//
//  Created by Анатолий on 09/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell, ReusableView {
    let stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()
    
    var imageViewWidth: NSLayoutConstraint!
    
    let tagLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
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
        clipsToBounds = false
        
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.125
        layer.shadowRadius = 2
        
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(tagLabel)
        addSubview(stack)
    }
    
    private func setupConstrains() {
        let constrains = [stack.topAnchor.constraint(equalTo: topAnchor),
                          stack.leadingAnchor.constraint(equalTo: leadingAnchor),
                          stack.trailingAnchor.constraint(equalTo: trailingAnchor),
                          stack.bottomAnchor.constraint(equalTo: bottomAnchor)]
        NSLayoutConstraint.activate(constrains)
        
        imageViewWidth = imageView.widthAnchor.constraint(equalToConstant: 0)
        imageViewWidth.isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
    }
    
    func configure(with settings: TagCellSettings) {
        stack.layoutMargins = settings.stackMargins
        stack.spacing = settings.stackSpacing
        imageViewWidth.constant = settings.iconSize
        tagLabel.font = UIFont.systemFont(ofSize: settings.fontSize)
        tagLabel.textColor = settings.textColor
        tagLabel.numberOfLines = settings.numberOfLines
        backgroundColor = settings.backgroundColor
        layer.cornerRadius = settings.cornerRadius
    }
}
