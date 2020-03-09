//
//  NoteBackgroundDataSource.swift
//  todo
//
//  Created by Анатолий on 08/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NoteBackgroundDataSource: NSObject {
    var backgrounds: [GradientBackgroud] = []

    override init() {
        super.init()
        initBackgrounds()
    }
}

// MARK: Helpers

extension NoteBackgroundDataSource {
    private func initBackgrounds() {
        backgrounds.append(createGradient(start: CGPoint(x: 0, y: 0),
                                          end: CGPoint(x: 1, y: 1),
                                          colors: [0xfdfbfb, 0xeaedee]))
        
        backgrounds.append(createGradient(start: CGPoint(x: 0, y: 0),
                                          end: CGPoint(x: 1, y: 1),
                                          colors: [0xfdfcfb, 0xe2d1c3]))
        
        backgrounds.append(createGradient(start: CGPoint(x: 0, y: 1),
                                          end: CGPoint(x: 1, y: 0),
                                          colors: [UIColor.Palette.yellow_soft.get.rgb!,
                                                   UIColor.Palette.orange_pale.get.rgb!]))
        
        backgrounds.append(createGradient(start: CGPoint(x: 0, y: 1),
                                          end: CGPoint(x: 1, y: 0),
                                          colors: [0xfad0c4, 0xff9a9e]))
        
        backgrounds.append(createGradient(start: CGPoint(x: 0, y: 1),
                                          end: CGPoint(x: 1, y: 0),
                                          colors: [UIColor.Palette.blue.get.lighter(diff: 0.1)!.rgb!,
                                                   UIColor.Palette.blue.get.rgb!]))

        backgrounds.append(createGradient(start: CGPoint(x: 0, y: 1),
                                          end: CGPoint(x: 1, y: 0),
                                          colors: [UIColor.Palette.cyan.get.lighter(diff: 0.1)!.rgb!,
                                                   UIColor.Palette.cyan.get.rgb!]))

        backgrounds.append(createGradient(start: CGPoint(x: 0, y: 1),
                                          end: CGPoint(x: 1, y: 0),
                                          colors: [UIColor.Palette.violet.get.lighter(diff: 0.05)!.rgb!,
                                                   UIColor.Palette.violet.get.rgb!]))

        backgrounds.append(createGradient(start: CGPoint(x: 0, y: 1),
                                          end: CGPoint(x: 1, y: 0),
                                          colors: [UIColor.Palette.pink.get.lighter(diff: 0.05)!.rgb!,
                                                   UIColor.Palette.pink.get.rgb!]))
    }

    func createGradient(start: CGPoint, end: CGPoint, colors: [Int32]) -> GradientBackgroud {
        let background = GradientBackgroud(entity: GradientBackgroud.entity(), insertInto: nil)
        background.startPoint = NSCoder.string(for: start)
        background.endPoint = NSCoder.string(for: end)
        background.colors = "[" + (colors.map { String($0) }).joined(separator: ",") + "]"
        return background
    }

    func getBackground(index: Int) -> GradientBackgroud {
        return backgrounds[index]
    }
}

// MARK: UICollectionViewDataSource

extension NoteBackgroundDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        backgrounds.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NoteGradientBackgroundCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: Configure cell

extension NoteBackgroundDataSource {
    func configure(cell: NoteGradientBackgroundCell, indexPath: IndexPath) {
        guard let layer = cell.noteView.layer as? CAGradientLayer else {
            return
        }
        let background = getBackground(index: indexPath.row)
        background.loadToLayer(layer: layer)
    }
}
