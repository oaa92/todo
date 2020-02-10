//
//  String.swift
//  todo
//
//  Created by Анатолий on 10/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

extension String {
    func frameSize(withMaxWidth width: CGFloat, font: UIFont) -> CGSize {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let attributes = [NSAttributedString.Key.font: font]
        let frame = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return frame.size
    }

    func frameSize(withMaxHeight height: CGFloat, font: UIFont) -> CGSize {
        let size = CGSize(width: .greatestFiniteMagnitude, height: height)
        let attributes = [NSAttributedString.Key.font: font]
        let frame = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return frame.size
    }
}
