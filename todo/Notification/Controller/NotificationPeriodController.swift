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

    let data = ["day", "week", "month", "year"]
    let numberOfComponents = 2

    // weak var delegate: NotificationDateProtocol?

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        customView.periodPickerView.dataSource = self
        customView.periodPickerView.delegate = self
        customView.weekdaysCollectionView.register(NotificationWeekdayCell.self)
        customView.weekdaysCollectionView.dataSource = self
        customView.layoutIfNeeded()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.curveTopCorners()
    }
}

// MARK: Helpers

extension NotificationPeriodController {
    private func selectLabel(_ pickerView: UIPickerView, row: Int, inComponent component: Int) {
        guard let label = pickerView.view(forRow: row, forComponent: component) as? UILabel else {
            return
        }
        label.textColor = UIColor.Palette.blue_soft.get
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    }
}

// MARK: Actions

extension NotificationPeriodController {}

// MARK: UIPickerViewDataSource

extension NotificationPeriodController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numberOfComponents
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? Int(Int8.max) : data.count
    }
}

// MARK: UIPickerViewDelegate

extension NotificationPeriodController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel
        if let pickerLabel = view as? UILabel {
            label = pickerLabel
        } else {
            label = createView(pickerView, viewForRow: row, forComponent: component)
        }
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectLabel(pickerView, row: row, inComponent: component)
    }
}

// MARK: Configure view in PickerView

extension NotificationPeriodController {
    private func createView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int) -> UILabel {
        let rowSize = pickerView.rowSize(forComponent: component)
        let frame = CGRect(x: 0, y: 0, width: rowSize.width, height: rowSize.height)
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.text = getTitle(viewForRow: row, forComponent: component)
        return label
    }

    private func getTitle(viewForRow row: Int, forComponent component: Int) -> String {
        if component == 0 {
            return row == 0 ? "every" : String(row + 1)
        } else {
            return data[row]
        }
    }
}

// MARK: UICollectionViewDataSource

extension NotificationPeriodController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NotificationWeekdayCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: Configure weekday cell

extension NotificationPeriodController {
    func configure(cell: NotificationWeekdayCell, indexPath: IndexPath) {
        cell.label.text = Calendar.autoupdatingCurrent.shortStandaloneWeekdaySymbols[indexPath.row]
    }
}
