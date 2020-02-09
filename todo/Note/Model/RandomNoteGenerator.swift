//
//  RandomNoteGenerator.swift
//  todo
//
//  Created by Анатолий on 06/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class RandomNoteGenerator {
    func generate(context: NSManagedObjectContext) -> Note {
        let note = Note(context: context)
        note.title = genRandomString(n: Int.random(in: 5...20), emptyPercent: 20, ending: "#")
        note.text = genNoteText()
        note.updatedAt = Date()
        note.background = genBackground(context: context)
        return note
    }
    
    private func genRandomString(n: Int, emptyPercent: Int, ending: String? = nil) -> String {
        guard Int.random(in: 1...100) > emptyPercent else {
            return ""
        }
        var title = ""
        for _ in 0..<n {
            if Int.random(in: 1...100) < 10 {
                title.append(" ")
                continue
            }
            let startCharValue = Unicode.Scalar("a").value
            let endCharValue = Unicode.Scalar("z").value
            let value = UInt32.random(in: startCharValue...endCharValue)
            if let char = UnicodeScalar(value)?.description {
                title.append(char)
            }
        }
        title = title.trimmingCharacters(in: CharacterSet.whitespaces)
        if let eStr = ending {
            title.append(eStr)
        }
        return title
    }
    
    private func genNoteText() -> String {
        var text = ""
        var n = 0
        if Int.random(in: 1...100) > 25 {
            n = Int.random(in: 10...50)
        } else {
            n = Int.random(in: 1...5)
        }
        for _ in 1...n {
            text += genRandomString(n: Int.random(in: 5...50), emptyPercent: 0) + " "
        }
        text += "#"
        return text
    }
    
    private func genBackground(context: NSManagedObjectContext) -> GradientBackgroud {
            let b = GradientBackgroud(context: context)
            b.startPoint = NSCoder.string(for: CGPoint(x: 0, y: 1))
            b.endPoint = NSCoder.string(for: CGPoint(x: 1, y: 0))
            let colors = [getRandomColor().rgb!,
                          getRandomColor().rgb!]
            b.colors = colors
            return b
    }
    
    private func getRandomColor() -> UIColor {
        let r = Int.random(in: 0...255)
        let g = Int.random(in: 0...255)
        let b = Int.random(in: 0...255)
        return UIColor(red: r, green: g, blue: b)
    }
}
