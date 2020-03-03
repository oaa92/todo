//
//  NotificationDateController.swift
//  todo
//
//  Created by Анатолий on 25/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Panels

class NotificationDateController: CustomViewController<NotificationDateView>, Panelable {
    lazy var headerHeight: NSLayoutConstraint! = customView.headerHeight
    lazy var headerPanel: UIView! = customView.headerPanel

    weak var delegate: NoteNotificationEditProtocol?

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        customView.layoutIfNeeded()
        customView.datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.curveTopCorners()
    }
}

// MARK: Actions

extension NotificationDateController {
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        guard let delegate = delegate else {
            return
        }
        delegate.dateDidChange(date: sender.date)
    }
}
