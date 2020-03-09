//
//  RandomNoteGenerator.swift
//  todo
//
//  Created by Анатолий on 06/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class RandomNoteGenerator {
    func generate(context: NSManagedObjectContext) -> Note {
        let note = Note(context: context)
        note.title = genRandomString(n: Int.random(in: 5...20), emptyPercent: 20, ending: "#")
        note.text = genNoteText()
        note.updatedAt = Date()
        note.background = genBackground(context: context)
        // tags
        if Int.random(in: 1...100) > 50 {
            let tagN = Int.random(in: 1...10)
            for _ in 0..<tagN {
                note.addToTags(genTag(context: context))
            }
        }
        
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
        b.colors = (colors.map { String($0) }).joined(separator: ",")
        return b
    }
    
    private func genTag(context: NSManagedObjectContext) -> Tag {
        let icons = ["angry",
                     "book",
                     "car",
                     "cart",
                     "doge",
                     "goal",
                     "heart",
                     "meeting",
                     "party",
                     "pills",
                     "sport",
                     "submarine",
                     "tag",
                     "work"]
        let t = Tag(context: context)
        t.name = genRandomString(n: 10, emptyPercent: 0)
        if Int.random(in: 1...100) > 50 {
            let i = Icon(context: context)
            i.color = getRandomColor().rgb!
            i.name = icons.randomElement()!
            t.icon = i
        }
        return t
    }
    
    private func getRandomColor() -> UIColor {
        let r = Int.random(in: 0...255)
        let g = Int.random(in: 0...255)
        let b = Int.random(in: 0...255)
        return UIColor(red: r, green: g, blue: b)
    }
}
