//
//  TagViewController.swift
//  todo
//
//  Created by Анатолий on 14/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
import UIKit

class TagViewController: CustomViewController<TagView> {
    var coreDataStack: CoreDataStack!
    var tag: Tag?
    let iconsDataSourse = TagIconDataSourse()
    let colorsDataSourse = TagColorDataSourse()

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        print("TagViewController viewDidLoad")
        customView.showIconView.addTarget(self, action: #selector(showIconValueChanged), for: .valueChanged)

        customView.iconsCollectionView.register(TagIconCell.self)
        customView.iconsCollectionView.dataSource = iconsDataSourse
        customView.iconsCollectionView.delegate = self

        customView.colorsCollectionView.register(TagColorCell.self)
        customView.colorsCollectionView.dataSource = colorsDataSourse
        customView.colorsCollectionView.delegate = self

        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("TagViewController viewWillAppear")
        customView.layoutIfNeeded()
        updateIconsAndColorsHeight()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveTag()
    }
}

// MARK: Helpers

extension TagViewController {
    private func updateUI() {
        guard let tag = tag else {
            customView.nameView.text = ""
            setIcon(icon: nil)
            return
        }
        customView.nameView.text = tag.name
        setIcon(icon: tag.icon)
    }

    private func setIcon(icon: Icon?) {
        if let icon = icon,
            let name = icon.name,
            let image = UIImage(named: name) {
            customView.iconView.image = image
            customView.iconView.tintColor = UIColor(hex6: icon.color)
            customView.iconView.alpha = 1
            customView.iconView.isHidden = false
            customView.showIconView.isOn = true
            customView.iconsCollectionView.isHidden = false
            customView.iconsCollectionView.alpha = 1
            customView.colorsCollectionView.isHidden = false
            customView.colorsCollectionView.alpha = 1
            selestIcon(icon: icon)
        } else {
            customView.iconView.image = nil
            customView.iconView.alpha = 0
            customView.iconView.isHidden = true
            customView.showIconView.isOn = false
            customView.iconsCollectionView.isHidden = true
            customView.iconsCollectionView.alpha = 0
            customView.colorsCollectionView.isHidden = true
            customView.colorsCollectionView.alpha = 0
        }
    }

    private func selestIcon(icon: Icon) {
        if let iconIndex = iconsDataSourse.iconNames.firstIndex(of: icon.name ?? "") {
            customView.iconsCollectionView.selectItem(at: IndexPath(row: iconIndex, section: 0),
                                                      animated: false,
                                                      scrollPosition: .centeredVertically)
        }

        if let colorIndex = colorsDataSourse.colors.firstIndex(where: { $0.rgb == icon.color }) {
            customView.colorsCollectionView.selectItem(at: IndexPath(row: colorIndex, section: 0),
                                                       animated: false,
                                                       scrollPosition: .centeredVertically)
        }
    }

    private func updateIconsAndColorsHeight() {
        let iconsHeight = customView.iconsCollectionView.collectionViewLayout.collectionViewContentSize.height
        customView.iconsCollectionHeight.constant = iconsHeight
        let colorsHeight = customView.colorsCollectionView.collectionViewLayout.collectionViewContentSize.height
        customView.colorsCollectionHeight.constant = colorsHeight
    }

    private func showIcon() {
        UIView.animate(withDuration: 0.2,
                       animations: { self.customView.iconView.isHidden = false },
                       completion: { _ in
                           UIView.animate(withDuration: 0.2,
                                          animations: { self.customView.iconView.alpha = 1 })
                       })
        TagViewAnimator.animateCollections(view: customView,
                                           hide: false,
                                           duration: 0.2).startAnimation()
    }

    private func hideIcon() {
        UIView.animate(withDuration: 0.2,
                       animations: { self.customView.iconView.alpha = 0 },
                       completion: { _ in
                           UIView.animate(withDuration: 0.2,
                                          animations: { self.customView.iconView.isHidden = true })
                       })
        TagViewAnimator.animateCollections(view: customView,
                                           hide: true,
                                           duration: 0.2).startAnimation()
    }

    private func getSelectedIcon() -> Icon? {
        if let iconIndex = customView.iconsCollectionView.indexPathsForSelectedItems?.first?.row,
            let colorIndex = customView.colorsCollectionView.indexPathsForSelectedItems?.first?.row,
            customView.showIconView.isOn {
            let name = iconsDataSourse.iconNames[iconIndex]
            let color = colorsDataSourse.colors[colorIndex]
            let icon = Icon(entity: Icon.entity(), insertInto: nil)
            icon.name = name
            icon.color = color.rgb!
            return icon
        }
        return nil
    }
}

// MARK: Core Data

extension TagViewController {
    private func saveTag() {
        let name: String = customView.nameView.text ?? ""
        guard !name.isEmpty else {
            return
        }

        let tag: Tag = self.tag ?? Tag(context: coreDataStack.managedContext)
        tag.name = name
        saveIcon(tag: tag)
        coreDataStack.saveContext()
    }

    private func saveIcon(tag: Tag) {
        // icon is off
        guard customView.showIconView.isOn else {
            deleteOldIconIfNeeded(icon: tag.icon)
            tag.icon = nil
            return
        }
        // not selected
        guard let selectedIcon = getSelectedIcon(),
            let selectedIconName = selectedIcon.name,
            !selectedIconName.isEmpty else {
            return
        }
        // equal
        if let icon = tag.icon,
            selectedIcon.name == icon.name,
            selectedIcon.color == icon.color {
            return
        }
        // search icon in core data
        let fetchRequest: NSFetchRequest<Icon> = Icon.fetchRequest()
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K = %@", #keyPath(Icon.name), selectedIconName),
            NSPredicate(format: "%K = %d", #keyPath(Icon.color), selectedIcon.color)
        ])
        fetchRequest.predicate = predicate
        do {
            let icons = try coreDataStack.managedContext.fetch(fetchRequest)
            if icons.count > 0 {
                deleteOldIconIfNeeded(icon: tag.icon)
                tag.icon = icons[0]
                return
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return
        }
        // insert icon to core data
        coreDataStack.managedContext.insert(selectedIcon)
        deleteOldIconIfNeeded(icon: tag.icon)
        tag.icon = selectedIcon
    }
    
    private func deleteOldIconIfNeeded(icon: Icon?) {
        guard let icon = icon else {
            return
        }
        if icon.tags?.count == 1 {
            coreDataStack.managedContext.delete(icon)
        }
    }
}

// MARK: Actions

extension TagViewController {
    @objc private func showIconValueChanged(sender: UISwitch) {
        if sender.isOn {
            showIcon()
            if tag?.icon == nil,
                (customView.iconsCollectionView.indexPathsForSelectedItems?.count ?? 0) == 0,
                (customView.colorsCollectionView.indexPathsForSelectedItems?.count ?? 0) == 0,
                iconsDataSourse.iconNames.count > 0, colorsDataSourse.colors.count > 0 {
                let icon = Icon(entity: Icon.entity(), insertInto: nil)
                icon.name = iconsDataSourse.iconNames[0]
                icon.color = colorsDataSourse.colors[0].rgb!
                setIcon(icon: icon)
            }
        } else {
            hideIcon()
        }
    }
}

// MARK: UICollectionViewDelegate

extension TagViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case customView.iconsCollectionView, customView.colorsCollectionView:
            if let icon = getSelectedIcon() {
                setIcon(icon: icon)
            }
        default:
            break
        }
    }
}
