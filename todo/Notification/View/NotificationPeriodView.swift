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

    let weekdays: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
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
        label.text = "Выберите период"
        addSubview(periodPickerView)
        addSubview(weekdays)
    }

    private func setupConstrains() {
        let periodPickerViewConstrains = [periodPickerView.topAnchor.constraint(equalTo: headerPanel.bottomAnchor),
                                          periodPickerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                                          periodPickerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                                          periodPickerView.heightAnchor.constraint(equalToConstant: 100)]
        NSLayoutConstraint.activate(periodPickerViewConstrains)

        let weekdaysConstrains = [weekdays.topAnchor.constraint(equalTo: periodPickerView.bottomAnchor),
                                  weekdays.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                                  weekdays.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                                  weekdays.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)]
        NSLayoutConstraint.activate(weekdaysConstrains)
    }
}
