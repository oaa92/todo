//
//  NotificationPeriodController.swift
//  todo
//
//  Created by Анатолий on 25/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Panels

class NotificationPeriodController: CustomViewController<NotificationPeriodView>, Panelable {
    lazy var headerHeight: NSLayoutConstraint! = customView.headerHeight
    lazy var headerPanel: UIView! = customView.headerPanel

    let data = ["день", "неделя", "месяц", "год"]
    let numberOfComponents = 2

    // weak var delegate: NotificationDateProtocol?

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        customView.periodPickerView.dataSource = self
        customView.periodPickerView.delegate = self
        customView.layoutIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.curveTopCorners()
    }

    // MARK: Actions

    /*
     @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
         guard let delegate = delegate else {
             return
         }
         delegate.dateDidChange(date: sender.date)
     }
     */
}

// MARK: UIPickerViewDataSource

extension NotificationPeriodController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numberOfComponents
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return data.count
        } else {
            return Int(Int8.max)
        }
    }
}

// MARK: UIPickerViewDelegate

extension NotificationPeriodController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return data[row]
        } else {
            if row == 0 {
                return "каждый"
            } else {
                return String(row + 1)
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {}
}
