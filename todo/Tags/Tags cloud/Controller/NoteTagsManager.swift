//
//  NoteTagsManager.swift
//  todo
//
//  Created by Анатолий on 04/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NoteTagsManager: NSObject {
    var locale: Locale!
    
    func tagsWithoutTemp(tags: [Tag]) -> [Tag] {
        let tags = tags.filter { !$0.isTemp }
        return tags
    }

    func getNotificationString(notifications: Set<NoteNotification>) -> String? {
        var notificationInfo: [(date: Date, period: PeriodType)] = []
        let notifications = notifications.compactMap({ $0 as? CalendarNotification })
        for notification in notifications {
            if let date = notification.date,
                let data = notification.period,
                let period = try? JSONDecoder().decode(PeriodType.self, from: data) {
                notificationInfo.append((date, period))
            }
        }
        
        guard let info = notificationInfo.first else {
            return nil
        }
        
        let format: String
        let hours = locale.usesAMPM() ? "hh" : "HH"
        switch info.period {
        case .none:
            return DateFormatter.localizedString(from: info.date, dateStyle: .medium, timeStyle: .short)
        case .daily, .weekly:
            format = "\(hours)mm"
        case .monthly:
            format = "dd\(hours)mm"
        case .annually:
            format = "MMMMdd\(hours)mm"
        }
        
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate(format)
        var notificationsString = formatter.string(from: info.date)
        
        if case .weekly = info.period {
            var weekdays: [Int] = []
            for info in notificationInfo {
                if case let .weekly(weekdays: weekdaysT) = info.period {
                    weekdays.append(contentsOf: weekdaysT ?? [])
                }
            }
            if weekdays.count > 0 {
                weekdays.sort()
                let weekdaysArrStr = weekdays.map { locale.getShortWeekday(index: $0) }
                let weekdaysStr = weekdaysArrStr.joined(separator: ", ")
                notificationsString.append(": \(weekdaysStr)")
                return notificationsString
            }
        } else {
            return notificationsString
        }
        return nil
    }
    
    func addNotificationTag(tags: [Tag], notifications: Set<NoteNotification>) -> [Tag] {
        guard let notificationsString = getNotificationString(notifications: notifications) else {
            return tags
        }
        var tagsWithNotification = tags
        let tag = Tag.createWithParams(name: notificationsString,
                                       icon: Icon.createWithParams(name: "notification",
                                                                   color: UIColor.Palette.blue_soft.get.rgb!),
                                       isTemp: true)
        tagsWithNotification.insert(tag, at: 0)
        return tagsWithNotification
    }
    
    func infoTags(from note: Note) -> [Tag] {
        var tags: [Tag] = []
        addInfoTag(tags: &tags,
                   date: note.createdAt,
                   icon: Icon.createWithParams(name: "plus",
                                               color: UIColor.Palette.cyan.get.rgb!))
        addInfoTag(tags: &tags,
                   date: note.updatedAt,
                   icon: Icon.createWithParams(name: "edit",
                                               color: UIColor.Palette.Buttons.edit.get.rgb!))
        addInfoTag(tags: &tags,
                   date: note.deletedAt,
                   icon: Icon.createWithParams(name: "trash",
                                               color: UIColor.Palette.Buttons.delete.get.rgb!))
        return tags
    }
    
    private func addInfoTag(tags: inout [Tag], date: Date?, icon: Icon?) {
        guard let date = date else {
            return
        }
        let tag = Tag.createWithParams(name: date.shortFormat(with: locale),
                                       icon: icon)
        tags.append(tag)
    }
    
    func tagsForMaxWidth(tags: [Tag], provider: TagsCloudDataSource, maxWidth: CGFloat) {
        let settings = provider.settings
        var sumWidth: CGFloat = 0
        var addTagsCount = 0
        for tag in tags {
            let size = provider.getSizeForTag(tag: tag, collectionViewWidth: maxWidth)
            sumWidth += size.width + settings.minimumInteritemSpacing
            if sumWidth >= maxWidth {
                if addTagsCount > 0 {
                    let otherTags = Tag.createWithParams(name: "+\(tags.count - addTagsCount)")
                    provider.tags.append(otherTags)
                } else {
                    provider.tags.append(tag)
                }
                break
            } else {
                provider.tags.append(tag)
                addTagsCount += 1
            }
        }
    }
}
