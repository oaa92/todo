//
//  MenuView.swift
//  todo
//
//  Created by Анатолий on 09/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class MenuView: UIView {
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
        addSubview(tableView)
    }
    
    private func setupConstrains() {
        let constrains = [tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                          tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                          tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                          tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)]
        NSLayoutConstraint.activate(constrains)
    }
}
