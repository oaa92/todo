//
//  TagIconDataSourse.swift
//  todo
//
//  Created by Анатолий on 16/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagIconDataSourse: NSObject {
    let iconNames = ["tag", "book", "car", "doge", "goal", "heart", "pills", "meeting", "sport", "submarine", "work"]
}

// MARK: UICollectionViewDataSource

extension TagIconDataSourse: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TagIconCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        let name = iconNames[indexPath.row]
        cell.iconView.image = UIImage(named: name)
        return cell
    }
}
