//
//  MenuView.swift
//  todo
//
//  Created by Анатолий on 09/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class MenuView: UIView {
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16
        
        stack.isLayoutMarginsRelativeArrangement = true
        
        return stack
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
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
        stackView.addArrangedSubview(tableView)
        addSubview(stackView)
    }
    
    private func setupConstrains() {
        let stackViewConstrains = [stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                                    stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                                    stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                                    stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)]
        NSLayoutConstraint.activate(stackViewConstrains)
    }
}
