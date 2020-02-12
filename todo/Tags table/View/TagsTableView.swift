//
//  TagsTableView.swift
//  todo
//
//  Created by Анатолий on 12/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagsTableView: UIView {
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.Palette.pale_orange.get
        button.setTitleColor(UIColor.black, for: .normal)
        return button
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
        button.isHidden = true
        stackView.addArrangedSubview(tableView)
        stackView.addArrangedSubview(button)
        addSubview(stackView)
    }
    
    private func setupConstrains() {
        let scrollViewConstrains = [stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                                    stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                                    stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                                    stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)]
        NSLayoutConstraint.activate(scrollViewConstrains)
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
}
