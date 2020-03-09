//
//  NotificationPeriodView.swift
//  todo
//
//  Created by Анатолий on 25/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NotificationPeriodView: PanelView {
    let periodPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = UIColor.Palette.grayish_orange.get
        return picker
    }()

    let weekdaysCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 48, height: 48)
        flowLayout.minimumInteritemSpacing = 4
        flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.Palette.grayish_orange.get
        view.allowsMultipleSelection = true
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
        label.text = "Выберите период"
        addSubview(periodPickerView)
        addSubview(weekdaysCollectionView)
    }

    private func setupConstrains() {
        let periodPickerViewConstrains = [periodPickerView.topAnchor.constraint(equalTo: headerPanel.bottomAnchor),
                                          periodPickerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                                          periodPickerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                                          periodPickerView.heightAnchor.constraint(equalToConstant: 120)]
        NSLayoutConstraint.activate(periodPickerViewConstrains)

        let weekdaysConstrains = [weekdaysCollectionView.topAnchor.constraint(equalTo: periodPickerView.bottomAnchor),
                                  weekdaysCollectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                                  weekdaysCollectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                                  weekdaysCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)]
        NSLayoutConstraint.activate(weekdaysConstrains)
    }
}
