//
//  NotificationPeriodView.swift
//  todo
//
//  Created by Анатолий on 25/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NotificationPeriodView: PanelView {
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()

    let periodPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = .clear
        picker.isHidden = true
        return picker
    }()

    let backButton: UIButton = {
        let button = UIButton()
        let title = NSLocalizedString("weekly", comment: "")
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(named: "back"), for: .normal)
        button.setTitleColor(UIColor.Palette.blue_soft.get, for: .normal)
        button.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        button.layer.cornerRadius = 16
        button.isHidden = true
        return button
    }()

    let weekdaysCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 56, height: 56)
        flowLayout.minimumInteritemSpacing = 16
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.allowsMultipleSelection = true
        view.isHidden = true
        return view
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
        label.text = NSLocalizedString("Select period", comment: "")
        stackView.addArrangedSubview(periodPickerView)
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(weekdaysCollectionView)
        addSubview(stackView)
    }

    private func setupConstrains() {
        let constrains = [stackView.topAnchor.constraint(equalTo: headerPanel.bottomAnchor),
                          stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                          stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                          stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                          backButton.heightAnchor.constraint(equalToConstant: 40)]
        NSLayoutConstraint.activate(constrains)
    }
}
