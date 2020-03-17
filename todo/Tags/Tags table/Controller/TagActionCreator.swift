//
//  TagActionCreator.swift
//  todo
//
//  Created by Анатолий on 13/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class TagActionCreator {
    var coreDataStack: CoreDataStack!

    func getDeleteAction(tag: Tag, completionBlock: (() -> ())? = nil) -> UIContextualAction {
        let title = NSLocalizedString("Delete", comment: "")
        let action = UIContextualAction(style: .destructive, title: title) { _, _, completionHandler in
            tag.delete(coreDataStack: self.coreDataStack)
            self.coreDataStack.saveContext()
            if let completionBlock = completionBlock {
                completionBlock()
            }
            completionHandler(true)
        }
        action.backgroundColor = UIColor.Palette.Buttons.delete.get
        action.image = UIImage(named: "trash")
        return action
    }

    func getEditAction(tag: Tag, navigationController: UINavigationController?, tagEditDelegate: TagEditProtocol? = nil) -> UIContextualAction {
        let title = NSLocalizedString("Edit", comment: "")
        let action = UIContextualAction(style: .normal, title: title) { _, _, completionHandler in
            let tagController = TagViewController()
            tagController.coreDataStack = self.coreDataStack
            tagController.tag = tag
            tagController.tagEditDelegate = tagEditDelegate
            navigationController?.pushViewController(tagController, animated: true)
            completionHandler(true)
        }
        action.backgroundColor = UIColor.Palette.Buttons.edit.get
        action.image = UIImage(named: "edit")
        return action
    }
}
