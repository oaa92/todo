//
//  NoteView.swift
//  todo
//
//  Created by Анатолий on 28/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NoteView: UIView {
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 16
        
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        return stackView
    }()
    
    let titleView: UITextField = {
        let titleView = UITextField()
        titleView.placeholder = "Title"
        titleView.font = UIFont.systemFont(ofSize: 24)
        return titleView
    }()
    
    let noteView: NoteTextView = {
        let noteView = NoteTextView()
        noteView.font = UIFont.systemFont(ofSize: 20)
        noteView.translatesAutoresizingMaskIntoConstraints = false
        noteView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        
        if let layer = noteView.layer as? CAGradientLayer {
            layer.startPoint = CGPoint(x: 0, y: 1)
            layer.endPoint = CGPoint(x: 1, y: 0)
        }
        
        return noteView
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
        backgroundColor = UIColor(hex6: 0xF7ECE1)
        
        stackView.addArrangedSubview(titleView)
        stackView.addArrangedSubview(noteView)
        
        scrollView.addSubview(stackView)
        addSubview(scrollView)
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
    }
}
