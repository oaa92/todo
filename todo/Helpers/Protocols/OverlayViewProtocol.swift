//
//  OverlayViewProtocol.swift
//  todo
//
//  Created by Анатолий on 08/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

protocol OverlayViewProtocol: UIViewController {
    var overlayView: UIView { get }
    
    func setupOverlayView()
    func showOverlayView(parent: UIView)
    func hideOverlayView()
}
