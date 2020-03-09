//
//  OverlayViewProtocol+utils.swift
//  todo
//
//  Created by Анатолий on 08/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

extension OverlayViewProtocol {
    func setupOverlayView() {
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    func showOverlayView(parent: UIView) {
        overlayView.frame = parent.frame
        parent.insertSubview(overlayView, at: 1)
    }
    
    func hideOverlayView() {
        overlayView.removeFromSuperview()
    }
}
