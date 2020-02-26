//
//  NotificationController.swift
//  todo
//
//  Created by Анатолий on 22/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Panels

class NotificationController: CustomViewController<NotificationView> {
    var date = Date()

    private lazy var notificationDateController: NotificationDateController = {
        let controller = NotificationDateController()
        controller.customView.datePickerView.date = self.date
        controller.delegate = self
        return controller
    }()

    private lazy var datePanelManager: Panels = {
        let panels = Panels(target: self)
        panels.delegate = self
        return panels
    }()

    private lazy var notificationPeriodController: NotificationPeriodController = {
        let controller = NotificationPeriodController()
        return controller
    }()

    private lazy var periodPanelManager: Panels = {
        let panels = Panels(target: self)
        panels.delegate = self
        return panels
    }()

    private var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()

    private var currentPanel: Panels?

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        customView.notificationSwitchView.addTarget(self,
                                                    action: #selector(notificationSwitchViewValueChanged),
                                                    for: .valueChanged)
        customView.periodSwitchView.addTarget(self,
                                              action: #selector(periodSwitchViewValueChanged),
                                              for: .valueChanged)

        let dateTap = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        customView.dateLabel.addGestureRecognizer(dateTap)

        let periodTap = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        customView.periodLabel.addGestureRecognizer(periodTap)

        updateDateLabel()
        updatePeriodLabel()
    }
}

// MARK: Helpers

extension NotificationController {
    private func updateDateLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: date)
        customView.dateLabel.text = dateString
    }

    private func updatePeriodLabel() {
        customView.periodLabel.text = "ежедневно"
    }

    private func insertOverlayView() {
        overlayView.frame = customView.frame
        customView.insertSubview(overlayView, at: 1)
    }

    private func panelDismiss(panelManager: Panels) {
        panelManager.dismiss()
        customView.gestureRecognizers?.forEach { customView.removeGestureRecognizer($0) }
        let controller = panelManager === datePanelManager ? notificationDateController : notificationPeriodController
        if let view = controller.view as? PanelView {
            let headerPanel = view.headerPanel
            headerPanel.gestureRecognizers?.forEach { headerPanel.removeGestureRecognizer($0) }
        }
        overlayView.removeFromSuperview()
    }

    private func animatePeriodLabel(alpha: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.customView.periodLabel.alpha = alpha
        }
    }
}

// MARK: Actions

extension NotificationController {
    @objc private func notificationSwitchViewValueChanged() {
        let alpha: CGFloat = customView.notificationSwitchView.isOn ? 1 : 0
        UIView.animate(withDuration: 0.2) {
            self.customView.dateLabel.alpha = alpha
            self.customView.periodStack.alpha = alpha
        }
        if customView.notificationSwitchView.isOn, customView.periodSwitchView.isOn {
            animatePeriodLabel(alpha: 1)
        } else {
            animatePeriodLabel(alpha: 0)
        }
    }

    @objc private func periodSwitchViewValueChanged() {
        let alpha: CGFloat = customView.periodSwitchView.isOn ? 1 : 0
        animatePeriodLabel(alpha: alpha)
    }

    @objc private func labelTapped(_ sender: UITapGestureRecognizer) {
        let panels = [datePanelManager, periodPanelManager]
        for panel in panels {
            if panel.isExpanded {
                return
            }
        }

        let panel: Panels
        var panelConfiguration: PanelConfiguration
        let controller: Panelable & UIViewController

        switch sender.view {
        case customView.dateLabel:
            panel = datePanelManager
            panelConfiguration = PanelConfiguration(size: .custom(300), margin: 0, visibleArea: 50)
            controller = notificationDateController
        case customView.periodLabel:
            panel = periodPanelManager
            panelConfiguration = PanelConfiguration(size: .custom(400), margin: 0, visibleArea: 50)
            controller = notificationPeriodController
        default:
            print("unknown view")
            return
        }
        panelConfiguration.animateEntry = true

        // show and open panel
        panel.show(panel: controller, config: panelConfiguration)
        panel.expandPanel()
        currentPanel = panel
    }
}

// MARK: NotificationDateProtocol

extension NotificationController: NotificationDateProtocol {
    func dateDidChange(date: Date) {
        self.date = date
        updateDateLabel()
    }
}

// MARK: PanelNotifications

extension NotificationController: PanelNotifications {
    func panelDidPresented() {
        insertOverlayView()
    }

    func panelDidOpen() {}

    func panelDidCollapse() {
        if let currentPanel = currentPanel {
            panelDismiss(panelManager: currentPanel)
        }
    }
}
