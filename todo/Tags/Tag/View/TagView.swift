//
//  TagView.swift
//  todo
//
//  Created by Анатолий on 14/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagView: UIView {
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16
        
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        
        return stack
    }()
    
    let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        stack.backgroundColor = .lightGray
        return stack
    }()
    
    let iconView: UIImageView = {
        let icon = UIImageView()
        icon.setContentHuggingPriority(.required, for: .horizontal)
        return icon
    }()
    
    let nameView: UITextField = {
        let name = UITextField()
        name.placeholder = NSLocalizedString("Tag title", comment: "")
        name.font = UIFont.systemFont(ofSize: 24)
        name.returnKeyType = .done
        name.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return name
    }()
    
    let showIconView: UISwitch = {
        let showIcon = UISwitch()
        showIcon.onTintColor = UIColor.Palette.blue_soft.get
        showIcon.setContentHuggingPriority(.required, for: .horizontal)
        return showIcon
    }()
    
    let iconsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    var iconsCollectionHeight: NSLayoutConstraint!
    
    let colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    var colorsCollectionHeight: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstrains()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = UIColor.Palette.grayish_orange.get
        headerStack.addArrangedSubview(iconView)
        headerStack.addArrangedSubview(nameView)
        stackView.addArrangedSubview(headerStack)
        setupSwitchStack()
        stackView.addArrangedSubview(iconsCollectionView)
        stackView.addArrangedSubview(colorsCollectionView)
        scrollView.addSubview(stackView)
        addSubview(scrollView)
    }
    
    private func setupSwitchStack() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        
        let label = UILabel()
        label.text = NSLocalizedString("Show icon", comment: "")
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(showIconView)
        stackView.addArrangedSubview(stack)
    }
    
    private func setupConstrains() {
        let scrollViewConstrains = [scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                                    scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                                    scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                                    scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)]
        NSLayoutConstraint.activate(scrollViewConstrains)
        
        let stackViewConstrains = [stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                                   stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                                   stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                                   stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                                   stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)]
        NSLayoutConstraint.activate(stackViewConstrains)
        
        iconView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor, multiplier: 1).isActive = true
        
        iconsCollectionHeight = iconsCollectionView.heightAnchor.constraint(equalToConstant: 50)
        iconsCollectionHeight.isActive = true
        
        colorsCollectionHeight = colorsCollectionView.heightAnchor.constraint(equalToConstant: 50)
        colorsCollectionHeight.isActive = true
    }
}
