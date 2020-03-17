//
//  PanelView.swift
//  todo
//
//  Created by Анатолий on 25/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class PanelView: UIView {
    var headerPanel: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.Palette.orange_pale.get
        return view
    }()
    
    var headerHeight: NSLayoutConstraint!
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.Palette.text.get
        label.backgroundColor = .clear
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
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.Palette.grayish_orange.get
        addSubview(headerPanel)
        headerPanel.addSubview(label)
    }
    
    private func setupConstrains() {
        headerHeight = headerPanel.heightAnchor.constraint(equalToConstant: 50)
        headerHeight.isActive = true
        
        let headerPanelConstrains = [headerPanel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                                     headerPanel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                                     headerPanel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)]
        NSLayoutConstraint.activate(headerPanelConstrains)
        
        let labelConstrains = [label.centerXAnchor.constraint(equalTo: headerPanel.centerXAnchor),
                               label.centerYAnchor.constraint(equalTo: headerPanel.centerYAnchor)]
        NSLayoutConstraint.activate(labelConstrains)
    }
}
