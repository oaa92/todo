//
//  NotificationDateView.swift
//  todo
//
//  Created by Анатолий on 25/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NotificationDateView: PanelView {
    let datePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.backgroundColor = UIColor.Palette.grayish_orange.get
        return datePicker
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
        label.text = NSLocalizedString("Select date", comment: "")
        addSubview(datePickerView)
    }
    
    private func setupConstrains() {
        let datePickerViewConstrains = [datePickerView.topAnchor.constraint(equalTo: headerPanel.bottomAnchor),
                                        datePickerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                                        datePickerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                                        datePickerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)]
        NSLayoutConstraint.activate(datePickerViewConstrains)
    }
}
