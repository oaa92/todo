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
        createBackground(colors: [0xfdfbfb, 0xeaedee])
        createBackground(colors: [0xfdfcfb, 0xe2d1c3])
        createBackground(colors: [UIColor.Palette.yellow_soft.get.rgb!,
                                  UIColor.Palette.orange_pale.get.rgb!])
        createBackground(colors: [0xfad0c4, 0xff9a9e])
        createBackground(colors: [UIColor.Palette.blue.get.lighter(diff: 0.1)!.rgb!,
                                  UIColor.Palette.blue.get.rgb!])
        createBackground(colors: [UIColor.Palette.cyan.get.lighter(diff: 0.1)!.rgb!,
                                  UIColor.Palette.cyan.get.rgb!])
        createBackground(colors: [UIColor.Palette.violet.get.lighter(diff: 0.05)!.rgb!,
                                  UIColor.Palette.violet.get.rgb!])
        createBackground(colors: [UIColor.Palette.pink.get.lighter(diff: 0.05)!.rgb!,
                                  UIColor.Palette.pink.get.rgb!])
    }

    private func createBackground(colors: [Int32]) {
        let start = CGPoint(x: 0, y: 1)
        let end = CGPoint(x: 1, y: 0)
        let background = GradientBackgroud.createWithParams(start: start,
                                                            end: end,
                                                            colors: colors)
        backgrounds.append(background)
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
