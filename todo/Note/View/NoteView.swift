//
//  NoteView.swift
//  todo
//
//  Created by Анатолий on 28/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Floaty

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
        titleView.placeholder = NSLocalizedString("Title", comment: "")
        titleView.font = UIFont.systemFont(ofSize: 24)
        titleView.textColor = UIColor.Palette.text.get
        titleView.returnKeyType = .done
        return titleView
    }()
    
    let noteView: NoteTextView = {
        let noteView = NoteTextView()
        noteView.translatesAutoresizingMaskIntoConstraints = false
        noteView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        noteView.font = UIFont.systemFont(ofSize: 20)
        noteView.textColor = UIColor.Palette.text.get
        return noteView
    }()
    
    let tagsView: TagsCloudCollectionView = {
        let tagsView = TagsCloudCollectionView(frame: .zero, collectionViewLayout: TagsCloudLayout())
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        tagsView.isHidden = true
        return tagsView
    }()
    
    var tagsViewHeight: NSLayoutConstraint!
    
    let infoView: TagsCloudCollectionView = {
        let tagsView = TagsCloudCollectionView(frame: .zero, collectionViewLayout: TagsCloudLayout())
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        tagsView.isHidden = true
        return tagsView
    }()
    
    var infoViewHeight: NSLayoutConstraint!
    
    lazy var floaty = Floaty()
    
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
        stackView.addArrangedSubview(titleView)
        stackView.addArrangedSubview(noteView)
        stackView.addArrangedSubview(tagsView)
        stackView.addArrangedSubview(infoView)
        scrollView.addSubview(stackView)
        addSubview(scrollView)
        addSubview(floaty)
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
        
        tagsViewHeight = tagsView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        tagsViewHeight.isActive = true
        
        infoViewHeight = infoView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        infoViewHeight.isActive = true
    }
}
