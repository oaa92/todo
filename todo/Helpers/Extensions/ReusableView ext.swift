//
//  ReusableView ext.swift
//  todo
//
//  Created by Анатолий on 29/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Foundation

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
