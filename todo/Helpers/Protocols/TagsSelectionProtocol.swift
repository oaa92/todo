//
//  TagsSelectionProtocol.swift
//  todo
//
//  Created by Анатолий on 20/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Foundation

protocol TagsSelectionProtocol: class {
    func tagsDidSelect(tags: [Tag])
}
