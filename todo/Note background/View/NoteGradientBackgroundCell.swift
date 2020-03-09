//
//  NoteGradientBackgroundCell.swift
//  todo
//
//  Created by Анатолий on 08/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NoteGradientBackgroundCell: UICollectionViewCell, ReusableView {
    let noteView: NoteTextView = {
        let noteView = NoteTextView()
        noteView.translatesAutoresizingMaskIntoConstraints = false
        noteView.isUserInteractionEnabled = false
        return noteView
    }()
    
    let borderColor = UIColor.clear.cgColor
    var selectedColor = UIColor.Palette.blue_soft.get.cgColor
    
    override var isSelected: Bool {
        didSet {
            let toColor = isSelected ? selectedColor : borderColor
            layer.borderColor = toColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstrains()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        layer.borderColor = borderColor
        layer.cornerRadius = 20
        layer.borderWidth = 5
        clipsToBounds = true
        
        addSubview(noteView)
    }
    
    private func setupConstrains() {
        let constraints = [noteView.topAnchor.constraint(equalTo: topAnchor),
                           noteView.leadingAnchor.constraint(equalTo: leadingAnchor),
                           noteView.trailingAnchor.constraint(equalTo: trailingAnchor),
                           noteView.bottomAnchor.constraint(equalTo: bottomAnchor)]
        NSLayoutConstraint.activate(constraints)
    }
}
