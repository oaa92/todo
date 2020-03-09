//
//  TagsCloudDataSource.swift
//  todo
//
//  Created by Анатолий on 10/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagsCloudDataSource: NSObject {
    var tags: [Tag] = []
    var isHaveImages: Bool {
        return tags.contains { $0.icon != nil }
    }

    let settings: TagsCloudSettings

    init(cellSettings: TagsCloudSettings) {
        settings = cellSettings
    }
}

// MARK: UICollectionViewDataSource

extension TagsCloudDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
	
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TagsCloudCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: settings)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: Tag cell configuration

extension TagsCloudDataSource {
    func configure(cell: TagsCloudCell, indexPath: IndexPath) {
        let tag = tags[indexPath.row]
        cell.tagLabel.text = tag.name
        if let icon = tag.icon,
            let iconName = icon.name,
            let image = UIImage(named: iconName),
            settings.iconSize > 0 {
            cell.imageView.isHidden = false
            cell.imageView.image = image
            cell.imageView.tintColor = UIColor(hex6: icon.color)
        } else {
            cell.imageView.isHidden = true
            cell.imageView.image = nil
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension TagsCloudDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 0, height: 0)
        }
        flowLayout.minimumInteritemSpacing = settings.minimumInteritemSpacing
        flowLayout.sectionInset = settings.collectionSectionInset

        let tag = tags[indexPath.row]
        let width = collectionView.bounds.width
        let size = getSizeForTag(tag: tag, collectionViewWidth: width)
        return size
    }

    func getSizeForTag(tag: Tag, collectionViewWidth: CGFloat) -> CGSize {
        let imageSize: CGFloat
        let imageSpace: CGFloat
        if tag.icon != nil,
            settings.iconSize > 0 {
            imageSize = settings.iconSize
            imageSpace = settings.stackSpacing
        } else {
            imageSize = 0
            imageSpace = 0
        }
        // get tag name frame
        let tagName = tag.name ?? ""
        let contentMaxWidth = collectionViewWidth -
            (settings.collectionSectionInset.left + settings.collectionSectionInset.right) -
            (settings.stackMargins.left + settings.stackMargins.right) -
            (imageSize + imageSpace)
        let frameSize = tagName.frameSize(withMaxWidth: contentMaxWidth,
                                          font: UIFont.systemFont(ofSize: settings.fontSize))
        // get cell width
        let width = settings.stackMargins.left + imageSize + imageSpace + frameSize.width.rounded(.up) + settings.stackMargins.right
        // get cell height
        // for image
        let imageH = isHaveImages ? settings.iconSize : 0
        let minHeightForImage = settings.stackMargins.top + imageH + settings.stackMargins.bottom + 2
        // for text
        let minHeightForText: CGFloat
        if settings.multiline {
            minHeightForText = settings.stackMargins.top + frameSize.height.rounded(.up) + settings.stackMargins.bottom + 2
        } else {
            // single-line text
            let frameSizeWithMaxWidth = tagName.frameSize(withMaxWidth: CGFloat.greatestFiniteMagnitude,
                                                          font: UIFont.systemFont(ofSize: settings.fontSize))
            minHeightForText = settings.stackMargins.top + frameSizeWithMaxWidth.height.rounded(.up) + settings.stackMargins.bottom + 2
        }
        let height = max(minHeightForImage, minHeightForText)

        return CGSize(width: width, height: height)
    }
}
