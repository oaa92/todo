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
        UIColor.Palette.yellow_pale.get,
        UIColor.Palette.orange_pale.get,
        UIColor.Palette.red.get,
        UIColor.Palette.green.get,
        UIColor.Palette.cyan_pale.get,
        UIColor.Palette.cyan.get,
        UIColor.Palette.blue.get,
        UIColor.Palette.blue_pale.get,
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
