//
//  NoteNotificationEditProtocol.swift
//  todo
//
//  Created by Анатолий on 25/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Foundation

protocol NoteNotificationEditProtocol: class {
    func dateDidChange(date: Date)
    func periodDidChange(period: PeriodType)
}
