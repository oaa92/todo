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
    
    func addNotificationTag(tags: [Tag], notifications: Set<NoteNotification>) -> [Tag] {
        var tagsWithNotification = tags
        var dates = notifications.compactMap { ($0 as? CalendarNotification)?.date }
        dates.sort()
        if let tag = createTempTag(date: dates.first, icon: "notification") {
            tagsWithNotification.insert(tag, at: 0)
        }
        return tagsWithNotification
    }
    
    func infoTags(from note: Note) -> [Tag] {
        var tags: [Tag] = []
        if let tag = createTempTag(date: note.createdAt, icon: "plus", color: UIColor.Palette.cyan.get.rgb ?? 0) {
            tags.append(tag)
        }
        if let tag = createTempTag(date: note.updatedAt, icon: "edit", color: UIColor.Palette.Buttons.edit.get.rgb ?? 0) {
            tags.append(tag)
        }
        if let tag = createTempTag(date: note.deletedAt, icon: "trash", color: UIColor.Palette.Buttons.delete.get.rgb ?? 0) {
            tags.append(tag)
        }
        return tags
    }
    
    private func createTempTag(date: Date?,
                               icon: String,
                               color: Int32 = UIColor.Palette.blue_soft.get.rgb ?? 0) -> Tag? {
        guard let date = date else {
            return nil
        }
        
        let tag = Tag.createTemp(name: date.shortFormat(with: locale),
                                 icon: icon,
                                 color: color)
        return tag
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
                    let otherTags = Tag(entity: Tag.entity(), insertInto: nil)
                    otherTags.name = "+\(tags.count - addTagsCount)"
                    otherTags.isTemp = true
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
