//
//  ToastView.swift
//  todo
//
//  Created by Анатолий on 17/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class ToastView: UIView {
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.alignment = .center
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 16
        
        stack.layoutMargins = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        
        return stack
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.textColor = UIColor.Palette.text.get
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
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        addSubview(stackView)
    }
    
    func setupConstrains() {
        let stackViewConstrains = [stackView.topAnchor.constraint(equalTo: topAnchor),
                                   stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                   stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                   stackView.bottomAnchor.constraint(equalTo: bottomAnchor)]
        NSLayoutConstraint.activate(stackViewConstrains)
        
        imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
    }
}
