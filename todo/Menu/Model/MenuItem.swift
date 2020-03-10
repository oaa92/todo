//
//  MenuItem.swift
//  todo
//
//  Created by Анатолий on 11/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Foundation

struct MenuItem {
    let tag: Tag
    let predicate: NSPredicate
    let showAddButton: Bool
}
