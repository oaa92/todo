//
//  NoteNotificationsProtocol.swift
//  todo
//
//  Created by Анатолий on 01/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Foundation

protocol NoteNotificationsProtocol: class {
    func notificationsDidSet(notifications: Set<NoteNotification>)
}
