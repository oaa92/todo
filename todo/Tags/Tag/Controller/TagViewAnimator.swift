//
//  TagViewAnimator.swift
//  todo
//
//  Created by Анатолий on 14/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagViewAnimator {
    static func animateCollections(view: TagView,
                                   hide: Bool,
                                   duration: TimeInterval) -> UIViewPropertyAnimator {
        let iconsAnimator = getAnimator(collectionView: view.iconsCollectionView,
                                        hide: hide,
                                        duration: duration)
        let colorsAnimator = getAnimator(collectionView: view.colorsCollectionView,
                                         hide: hide,
                                         duration: duration)
        if hide {
            colorsAnimator.addCompletion { _ in iconsAnimator.startAnimation() }
            return colorsAnimator
        } else {
            iconsAnimator.addCompletion { _ in colorsAnimator.startAnimation() }
            return iconsAnimator
        }
    }

    private static func getAnimator(collectionView: UICollectionView,
                                    hide: Bool,
                                    duration: TimeInterval) -> UIViewPropertyAnimator {
        let alpha: CGFloat = hide ? 0 : 1
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: nil)
        animator.addAnimations {
            collectionView.alpha = alpha
            collectionView.isHidden = hide
        }
        return animator
    }
}
