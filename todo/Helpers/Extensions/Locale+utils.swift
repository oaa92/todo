//
//  Locale+utils.swift
//  todo
//
//  Created by Анатолий on 29/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Foundation

extension Locale {
    func getShortStandaloneWeekday(index: Int) -> String {
        let index = getWeekdayIndex(index: index)
        return self.calendar.shortStandaloneWeekdaySymbols[index]
    }
    
    func getWeekday(index: Int) -> String {
        let index = getWeekdayIndex(index: index)
        return self.calendar.weekdaySymbols[index]
    }
    
    private func getWeekdayIndex(index: Int) -> Int {
        var index = index + self.calendar.firstWeekday - 1
        if index == 7 {
            index = 0
        }
        return index
    }
}
