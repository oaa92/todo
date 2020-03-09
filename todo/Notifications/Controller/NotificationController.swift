//
//  NotificationController.swift
//  todo
//
//  Created by Анатолий on 22/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Panels

class NotificationController: CustomViewController<NotificationView>, OverlayViewProtocol {
    var locale = Locale.autoupdatingCurrent
    var coreDataStack: CoreDataStack!
    var notifications: Set<NoteNotification> = []
    weak var noteNotificationsDelegate: NoteNotificationsProtocol?
    
    var overlayView = UIView()

    private var date = Date()
    private var period: PeriodType = .none
    private let toastManager = ToastManager()

    private lazy var notificationDateController: NotificationDateController = {
        let controller = NotificationDateController()
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
        controller.delegate = self
        controller.locale = self.locale
        return controller
    }()

    private lazy var periodPanelManager: Panels = {
        let panels = Panels(target: self)
        panels.delegate = self
        return panels
    }()

    private var currentPanel: Panels?

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOverlayView()
        
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

        updateUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = noteNotificationsDelegate {
            if !customView.periodSwitchView.isOn {
                period = .none
            }
            notifications.removeAll()
            saveCalendarNotifications()
            
            delegate.notificationsDidSet(notifications: notifications)
        }
    }
}

// MARK: Helpers

extension NotificationController {
    private func updateUI() {
        if loadCalendarNotifications() {
            customView.notificationSwitchView.isOn = true
            customView.dateLabel.alpha = 1
            customView.periodStack.alpha = 1
            if period != .none {
                customView.periodSwitchView.isOn = true
                updatePeriodLabel()
                customView.periodLabel.alpha = 1
            }
        }
        updateDateLabel()
        updatePeriodController()
        notificationDateController.customView.datePickerView.date = date
    }

    private func updateDateLabel() {
        if period == .none || !customView.periodSwitchView.isOn {
            customView.dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
            return
        }

        let format: String
        let hours = locale.usesAMPM() ? "hh" : "HH"
        switch period {
        case .daily, .weekly:
            format = "\(hours)mm"
        case .monthly:
            format = "dd\(hours)mm"
        case .annually:
            format = "MMMMdd\(hours)mm"
        default:
            customView.dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
            return
        }

        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate(format)
        let dateString = formatter.string(from: date)
        customView.dateLabel.text = dateString
    }

    private func updatePeriodLabel() {
        var text = period.name

        if case let .weekly(weekdays: weekdaysTemp) = period,
            let weekdays = weekdaysTemp,
            weekdays.count > 0 {
            let weekdaysArrStr = weekdays.map { locale.getWeekday(index: $0) }
            let weekdaysStr = weekdaysArrStr.joined(separator: ", ")
            text.append(": \(weekdaysStr)")
        }

        customView.periodLabel.text = text
    }

    private func updatePeriodController() {
        var weekly: PeriodType
        if case PeriodType.weekly = period {
            weekly = period
        } else {
            weekly = PeriodType.weekly(weekdays: nil)
        }
        notificationPeriodController.periods = [.daily, weekly, .monthly, .annually]
        notificationPeriodController.selectPeriod(period: period)
    }

    private func animatePeriodLabel(alpha: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.customView.periodLabel.alpha = alpha
        }
    }
}

// MARK: Load notifications

extension NotificationController {
    private func loadCalendarNotifications() -> Bool {
        let calendarNotifications = self.notifications.compactMap { $0 as? CalendarNotification }
        guard calendarNotifications.count > 0 else {
            return false
        }

        let notifications: [(Date, PeriodType)] = calendarNotifications.compactMap {
            if let date = $0.date,
                let periodData = $0.period,
                let period = try? JSONDecoder().decode(PeriodType.self, from: periodData) {
                return (date, period)
            } else {
                return nil
            }
        }
        
        var weekdays: [Int] = []
        var wdate: Date = Date()
        for (date, period) in notifications {
            if case let .weekly(weekdays: weekdaysT) = period {
                if let weekdaysT = weekdaysT {
                    weekdays.append(contentsOf: weekdaysT)
                    wdate = date
                }
            } else {
                self.date = date
                self.period = period
                return true
            }
        }
        if weekdays.count > 0 {
            weekdays = Array(Set(weekdays))
            period = .weekly(weekdays: weekdays)
            date = wdate
            return true
        }
        return false
    }
}

// MARK: Create notifications

extension NotificationController {
    private func saveCalendarNotifications() {
        if case let .weekly(weekdays: weekdays) = period {
            // create notification for every weekday
            weekdays?.forEach {
                saveCalendarNotification(date: date, period: .weekly(weekdays: [$0]))
            }
        } else {
            saveCalendarNotification(date: date, period: period)
        }
    }

    private func saveCalendarNotification(date: Date, period: PeriodType) {
        guard let notification = createCalendarNotification(date: date, period: period) else {
            return
        }
        notifications.insert(notification)
    }

    private func createCalendarNotification(date: Date, period: PeriodType) -> CalendarNotification? {
        let encoder = JSONEncoder()
        let data: Data
        do {
            data = try encoder.encode(period)
        } catch {
            print(error.localizedDescription)
            return nil
        }

        let notification = CalendarNotification(entity: CalendarNotification.entity(), insertInto: nil)
        notification.uid = UUID().uuidString
        notification.date = date
        notification.period = data
        return notification
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
        if customView.periodSwitchView.isOn, period == .none {
            period = .daily
            notificationPeriodController.selectPeriod(period: period)
        }
        
        updateDateLabel()
        updatePeriodLabel()

        let alpha: CGFloat = customView.periodSwitchView.isOn ? 1 : 0
        animatePeriodLabel(alpha: alpha)
    }

    @objc private func labelTapped(_ sender: UITapGestureRecognizer) {
        switch sender.view {
        case customView.dateLabel:
            showPanel(panel: datePanelManager,
                      size: .custom(300),
                      controller: notificationDateController)
        case customView.periodLabel:
            showPanel(panel: periodPanelManager,
                      size: .custom(312),
                      controller: notificationPeriodController)
        default:
            print("unknown view")
            return
        }
    }
}

// MARK: NoteNotificationEditProtocol

extension NotificationController: NoteNotificationEditProtocol {
    func dateDidChange(date: Date) {
        self.date = date
        updateDateLabel()
    }

    func periodDidChange(period: PeriodType) {
        self.period = period
        updateDateLabel()
        updatePeriodLabel()
    }
}

// MARK: Panels

extension NotificationController {
    private func showPanel(panel: Panels, size: PanelDimensions, controller: Panelable & UIViewController) {
        var configuration = PanelConfiguration(size: size, margin: 0, visibleArea: 50)
        configuration.animateEntry = true
        panel.show(panel: controller, config: configuration)
        panel.expandPanel()
        currentPanel = panel
    }

    private func panelDismiss(panelManager: Panels) {
        panelManager.dismiss()
        customView.gestureRecognizers?.forEach { customView.removeGestureRecognizer($0) }
        let controller = panelManager === datePanelManager ? notificationDateController : notificationPeriodController
        if let view = controller.view as? PanelView {
            let headerPanel = view.headerPanel
            headerPanel.gestureRecognizers?.forEach { headerPanel.removeGestureRecognizer($0) }
        }
        hideOverlayView()
    }
}

// MARK: PanelNotifications

extension NotificationController: PanelNotifications {
    func panelDidPresented() {
        showOverlayView(parent: customView)
    }

    func panelDidOpen() {}

    func panelDidCollapse() {
        guard let currentPanel = currentPanel else {
            return
        }
        panelDismiss(panelManager: currentPanel)
        if currentPanel === periodPanelManager,
            case let .weekly(weekdays: weekdays) = period,
            weekdays?.count ?? 0 == 0 {
            toastManager.show(message: "Weekday's not selected", controller: self)
        }
    }
}
