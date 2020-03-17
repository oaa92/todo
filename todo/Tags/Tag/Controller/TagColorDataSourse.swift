//
//  TagColorDataSourse.swift
//  todo
//
//  Created by Анатолий on 16/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagColorDataSourse: NSObject {
    let colors: [UIColor] = [
        .white,
        UIColor(hex6: 0xEB5C5C),
        UIColor(hex6: 0xFFD500),
        UIColor(hex6: 0xFF8F57),
        UIColor.Palette.green.get,
        UIColor(hex6: 0x76E1E5),
        UIColor.Palette.cyan.get,
        UIColor.Palette.blue.get,
        UIColor(hex6: 0xC9C9FF),
        UIColor.Palette.violet.get,
        UIColor.Palette.pink.get,
        UIColor(hex6: 0x5D737E)
    ]
}

// MARK: UICollectionViewDataSource

extension TagColorDataSourse: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TagColorCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        let color = colors[indexPath.row]
        cell.colorView.borderColor = .clear
        cell.colorView.color = color
        return cell
    }
}
