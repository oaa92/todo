//
//  NoteCell.swift
//  todo
//
//  Created by Анатолий on 29/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell, ReusableView {
    let stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = .gray
        return titleLabel
    }()
    
    let noteView: NoteTextView = {
        let noteView = NoteTextView()
        noteView.translatesAutoresizingMaskIntoConstraints = false
        noteView.heightAnchor.constraint(lessThanOrEqualToConstant: 110).isActive = true
        noteView.isUserInteractionEnabled = false
        noteView.font = UIFont.systemFont(ofSize: 15)
        noteView.textColor = UIColor(hex6: 0x424C55)
        return noteView
    }()
    
    let tagsView: TagsCollectionView = {
        let tagsView = TagsCollectionView(frame: .zero, collectionViewLayout: TagsLayout())
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        tagsView.isUserInteractionEnabled = false
        return tagsView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstrains()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // title
        titleLabel.isHidden = true
        titleLabel.text = ""
        // noteView
        setupLayerParams()
        noteView.text = ""
        // tags
        tagsView.isHidden = true
    }
    
    private func setupViews() {
        titleLabel.isHidden = true
        tagsView.isHidden = true
        backgroundColor = .clear
        setupLayerParams()
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(noteView)
        stack.addArrangedSubview(tagsView)
        addSubview(stack)
    }
    
    private func setupLayerParams() {
        if let layer = noteView.layer as? CAGradientLayer {
            layer.startPoint = CGPoint(x: 0, y: 1)
            layer.endPoint = CGPoint(x: 1, y: 0)
            layer.colors = [UIColor.Palette.soft_yellow.get.cgColor,
                            UIColor.Palette.pale_orange.get.cgColor]
        }
    }
    
    private func setupConstrains() {
        let constrains = [stack.topAnchor.constraint(equalTo: topAnchor),
                          stack.leadingAnchor.constraint(equalTo: leadingAnchor),
                          stack.trailingAnchor.constraint(equalTo: trailingAnchor),
                          stack.bottomAnchor.constraint(equalTo: bottomAnchor)]
        NSLayoutConstraint.activate(constrains)
        tagsView.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(false, animated: animated)
    }
}
