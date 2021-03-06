//
//  TagsCloudCollectionView.swift
//  todo
//
//  Created by Анатолий on 09/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagsCloudCollectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        isScrollEnabled = false
        backgroundColor = .clear
    }
}
