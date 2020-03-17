//
//  NoteBackgroundController.swift
//  todo
//
//  Created by Анатолий on 08/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NoteBackgroundController: CustomViewController<NoteBackgroundView> {
    weak var backgroundSelectionDelegate: NoteBackgroundProtocol?
    var background: GradientBackgroud?
    
    private let colorsDataSource = NoteBackgroundDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customView.colorsCollectionView.register(NoteGradientBackgroundCell.self)
        customView.colorsCollectionView.dataSource = colorsDataSource
        selectBackground()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = backgroundSelectionDelegate,
            let path = customView.colorsCollectionView.indexPathsForSelectedItems?.first {
            delegate.backgroundDidSet(background: colorsDataSource.getBackground(index: path.row))
        }
    }
}

extension NoteBackgroundController {
    private func selectBackground() {
        guard let background = background else {
            return
        }
        
        for (index, backgroundI) in colorsDataSource.backgrounds.enumerated() {
            if backgroundI.compare(with: background) {
                customView.colorsCollectionView.selectItem(at: IndexPath(row: index, section: 0),
                                                           animated: true,
                                                           scrollPosition: .centeredVertically)
                break
            }
        }
    }
}
