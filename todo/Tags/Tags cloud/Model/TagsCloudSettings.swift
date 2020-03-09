//
//  TagsCloudSettings.swift
//  todo
//
//  Created by Анатолий on 09/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

struct TagsCloudSettings {
    let collectionSectionInset: UIEdgeInsets
    let minimumInteritemSpacing: CGFloat
    let stackMargins: UIEdgeInsets
    let stackSpacing: CGFloat
    let iconSize: CGFloat
    let fontSize: CGFloat
    var multiline: Bool = false
    let textColor: UIColor
    let backgroundColor: UIColor
    let cornerRadius: CGFloat

    var numberOfLines: Int {
        return multiline ? 0 : 1
    }
}
