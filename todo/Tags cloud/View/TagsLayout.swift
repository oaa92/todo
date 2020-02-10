//
//  TagsLayout.swift
//  todo
//
//  Created by Анатолий on 09/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagsLayout: UICollectionViewFlowLayout {
    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        cachedAttributes.removeAll()
        
        let contentWidth = collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        let count = collectionView.numberOfItems(inSection: 0)
        
        for currentIndex in 0..<count {
            guard let currentItemAttributes = super.layoutAttributesForItem(at: IndexPath(item: currentIndex, section: 0))?.copy() as? UICollectionViewLayoutAttributes else {
                return
            }
            
            if currentIndex == 0 {
                currentItemAttributes.frame.origin.x = sectionInset.left
                cachedAttributes.append(currentItemAttributes)
                continue
            }
            
            let previousFrame = cachedAttributes[currentIndex - 1].frame
            let previousFrameRightPoint = previousFrame.origin.x + previousFrame.width
            
            let currentFrame = currentItemAttributes.frame
            let strecthedCurrentFrame = CGRect(x: sectionInset.left,
                                               y: currentFrame.origin.y,
                                               width: contentWidth,
                                               height: currentFrame.size.height)
            
            let isFirstItemInRow = !previousFrame.intersects(strecthedCurrentFrame)
            if isFirstItemInRow {
                currentItemAttributes.frame.origin.x = sectionInset.left
                cachedAttributes.append(currentItemAttributes)
                continue
            }
            
            var frame = currentItemAttributes.frame
            frame.origin.x = previousFrameRightPoint + minimumInteritemSpacing
            frame.origin.y = previousFrame.origin.y
            currentItemAttributes.frame = frame
            cachedAttributes.append(currentItemAttributes)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.row]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        // Find any cell that sits within the query rect.
        guard let lastIndex = cachedAttributes.indices.last,
            let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex) else { return attributesArray }
        
        // Starting from the match, loop up and down through the array until all the attributes
        // have been added within the query rect.
        for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            attributesArray.append(attributes)
        }
        
        for attributes in cachedAttributes[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            attributesArray.append(attributes)
        }
        
        return attributesArray
    }
    
    // Perform a binary search on the cached attributes array.
    func binSearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start { return nil }
        
        let mid = (start + end) / 2
        let attr = cachedAttributes[mid]
        
        if attr.frame.intersects(rect) {
            return mid
        } else {
            if attr.frame.maxY < rect.minY {
                return binSearch(rect, start: mid + 1, end: end)
            } else {
                return binSearch(rect, start: start, end: mid - 1)
            }
        }
    }
}
