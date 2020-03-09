//
//  Date+utils.swift
//  todo
//
//  Created by Анатолий on 04/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Foundation

extension Date {
    func shortFormat(with locale: Locale) -> String {
        let components: Set<Calendar.Component> = [.day, .month, .year]
        let dateComponents = locale.calendar.dateComponents(components, from: self)
        let todayComponents = locale.calendar.dateComponents([.year], from: Date())
        let month = "MMM"
        let day = "d"
        let hours = locale.usesAMPM() ? "h" : "H"
        let minutes = "m"
        let format: String
        if dateComponents == todayComponents {
            format = hours + minutes
        } else if dateComponents.year == todayComponents.year {
            format = month + day + hours + minutes
        } else {
            format = "yy" + month + day + hours + minutes
        }
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate(format)
        let dateStr = formatter.string(from: self)
        return dateStr
    }
}
