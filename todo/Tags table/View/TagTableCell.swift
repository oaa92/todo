//
//  TagTableCell.swift
//  todo
//
//  Created by Анатолий on 12/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagTableCell: UITableViewCell, ReusableView {
    func configure(text: String?, imageName: String?, color: Int32?) {
        backgroundColor = .clear
        separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 10)
        textLabel?.text = text
        if let imageName = imageName,
            let image = UIImage(named: imageName),
            let color = color {
            imageView?.image = image
            imageView?.tintColor = UIColor(hex6: color)
        } else {
            imageView?.image = nil
            imageView?.tintColor = .white
        }
    }
}
