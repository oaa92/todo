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

    var periods: [PeriodType] = [.daily, .weekly(weekdays: nil), .monthly, .annually]
    var locale: Locale!
    weak var delegate: NoteNotificationEditProtocol?

    private let numberOfComponents = 1

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        customView.layoutIfNeeded()
        customView.periodPickerView.dataSource = self
        customView.periodPickerView.delegate = self
        customView.backButton.addTarget(self, action: #selector(tapBackButton), for: .touchUpInside)
        customView.weekdaysCollectionView.register(NotificationWeekdayCell.self)
        customView.weekdaysCollectionView.dataSource = self
        customView.weekdaysCollectionView.delegate = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.curveTopCorners()
    }
}

// MARK: Helpers

extension NotificationPeriodController {
    private func getPeriod(row: Int, forComponent component: Int) -> PeriodType {
        guard component == 0 else {
            return .none
        }
        return periods[row]
    }

    private func rowDidSelectInPeriodPickerView(didSelectRow row: Int, inComponent component: Int) {
        selectLabel(row: row, inComponent: component)
        updateWeekdaysTableVisible()
    }

    private func selectLabel(row: Int, inComponent component: Int) {
        guard let label = customView.periodPickerView.view(forRow: row, forComponent: component) as? UILabel else {
            return
        }
        label.textColor = UIColor.Palette.blue_soft.get
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    }

    private func updateWeekdaysTableVisible() {
        var hideWeekdaysTable = true
        let row = customView.periodPickerView.selectedRow(inComponent: 0)
        if row >= 0 {
            let period = getPeriod(row: row, forComponent: 0)
            if case .weekly = period {
                hideWeekdaysTable = false
            }
        }

        customView.layoutIfNeeded()
        if hideWeekdaysTable {
            customView.periodPickerView.isHidden = false
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.customView.periodPickerView.isHidden = true
                self.customView.layoutIfNeeded()
            }) {
                _ in
                UIView.animate(withDuration: 0.2) {
                    self.customView.backButton.isHidden = false
                    self.customView.weekdaysCollectionView.isHidden = false
                    self.customView.layoutIfNeeded()
                }
            }
        }
    }

    private func updatePeriod() {
        guard let delegate = delegate else { return }
        let row = customView.periodPickerView.selectedRow(inComponent: 0)
        guard row >= 0 else { return }

        var period = getPeriod(row: row, forComponent: 0)

        // set weekdays from table
        if case .weekly = period {
            var weekdays: [Int]?
            if let indexPaths = customView.weekdaysCollectionView.indexPathsForSelectedItems {
                weekdays = (indexPaths.map { $0.row }).sorted()
            } else {
                weekdays = nil
            }
            period = .weekly(weekdays: weekdays)
            periods[row] = period
        }

        delegate.periodDidChange(period: period)
    }

    func selectPeriod(period: PeriodType) {
        guard let index = periods.firstIndex(of: period) else {
            return
        }

        // select weekdays in table
        if case let .weekly(weekdays: weekdays) = period {
            if let paths = customView.weekdaysCollectionView.indexPathsForSelectedItems {
                paths.forEach { customView.weekdaysCollectionView.deselectItem(at: $0, animated: false) }
            }
            weekdays?.forEach {
                let index = IndexPath(row: $0, section: 0)
                customView.weekdaysCollectionView.selectItem(at: index, animated: false, scrollPosition: .top)
            }
        }

        customView.periodPickerView.selectRow(index, inComponent: 0, animated: false)
        rowDidSelectInPeriodPickerView(didSelectRow: index, inComponent: 0)
    }
}

// MARK: Actions

extension NotificationPeriodController {
    @objc func tapBackButton() {
        customView.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.customView.backButton.isHidden = true
            self.customView.weekdaysCollectionView.isHidden = true
            self.customView.layoutIfNeeded()
        }) {
            _ in
            UIView.animate(withDuration: 0.2) {
                self.customView.periodPickerView.isHidden = false
                self.customView.layoutIfNeeded()
            }
        }
    }
}

// MARK: UIPickerViewDataSource

extension NotificationPeriodController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numberOfComponents
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return periods.count
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
        rowDidSelectInPeriodPickerView(didSelectRow: row, inComponent: component)
        updatePeriod()
    }
}

// MARK: Configure view in PickerView

extension NotificationPeriodController {
    private func createView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int) -> UILabel {
        let rowSize = pickerView.rowSize(forComponent: component)
        let frame = CGRect(x: 0, y: 0, width: rowSize.width, height: rowSize.height)
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.text = getPeriod(row: row, forComponent: component).name
        return label
    }
}

// MARK: UICollectionViewDataSource

extension NotificationPeriodController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locale.calendar.weekdaySymbols.count
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
        cell.label.text = locale.getShortStandaloneWeekday(index: indexPath.row)
    }
}

// MARK: UICollectionViewDelegate

extension NotificationPeriodController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updatePeriod()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updatePeriod()
    }
}
