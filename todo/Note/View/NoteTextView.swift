//
//  NoteTextView.swift
//  todo
//
//  Created by Анатолий on 28/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NoteTextView: UITextView {
    
    override class var layerClass : AnyClass {
        return CAGradientLayer.self
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        configurate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurate() {
        isScrollEnabled = false
        
        let radius: CGFloat = 20
        layer.cornerRadius = radius
        clipsToBounds = false
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 4
        
        let insV = radius/2
        textContainerInset = UIEdgeInsets(top: insV, left: insV, bottom: insV, right: insV)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = .byTruncatingTail
    }
}
