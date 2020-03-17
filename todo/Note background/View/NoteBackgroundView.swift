//
//  NoteBackgroundView.swift
//  todo
//
//  Created by Анатолий on 08/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NoteBackgroundView: UIView {
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16
        
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        
        return stack
    }()
    
    let colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 130, height: 130)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
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
        backgroundColor = UIColor.Palette.grayish_orange.get
        stackView.addArrangedSubview(colorsCollectionView)
        addSubview(stackView)
    }
    
    private func setupConstrains() {
        let constrains = [stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                          stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                          stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                          stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)]
        NSLayoutConstraint.activate(constrains)
    }
}
