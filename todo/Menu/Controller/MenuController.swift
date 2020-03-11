//
//  MenuController.swift
//  todo
//
//  Created by Анатолий on 09/03/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
import UIKit

class MenuController: CustomViewController<MenuView> {
    var locale: Locale!
    var coreDataStack: CoreDataStack!
    var notificationsManager: NotificationsManager!

    private let headersSection = 0
    private let tagsSection = 1
    private var items: [[MenuItem]] = [[], []]

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        customView.tableView.register(TagTableCell.self)
        customView.tableView.dataSource = self
        customView.tableView.delegate = self

        updateData()
    }
}

extension MenuController {
    private func updateData() {
        headers()
        fetchTags()
        customView.tableView.reloadData()
    }

    private func headers() {
        addNotes()
        addNotifications()
        addTrash()
    }

    private func addNotes() {
        let item = MenuItem(tag: Tag.createTemp(name: NSLocalizedString("Notes", comment: ""),
                                                icon: nil,
                                                color: nil),
                            predicate: NSPredicate(format: "%K = nil", #keyPath(Note.deletedAt)),
                            showAddButton: true)
        items[headersSection].append(item)
    }

    private func addNotifications() {
        let item = MenuItem(tag: Tag.createTemp(name: NSLocalizedString("Notifications", comment: ""),
                                                icon: "notification",
                                                color: UIColor.Palette.blue_soft.get.rgb),
                            predicate: NSPredicate(format: "%K.@count > 0", #keyPath(Note.notifications)),
                            showAddButton: true)
        items[headersSection].append(item)
    }

    private func addTrash() {
        let item = MenuItem(tag: Tag.createTemp(name: NSLocalizedString("Trash", comment: ""),
        icon: "trash",
        color: UIColor.Palette.Buttons.delete.get.rgb),
                            predicate: NSPredicate(format: "%K != nil", #keyPath(Note.deletedAt)),
                            showAddButton: false)
        items[headersSection].append(item)
    }

    private func fetchTags() {
        do {
            let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
            let predicate = NSPredicate(format: "notes.@count > 0")
            fetchRequest.predicate = predicate
            let tags = try coreDataStack.managedContext.fetch(fetchRequest)
            
            for tag in tags {
                let item = MenuItem(tag: tag,
                                    predicate: NSPredicate(format: "SOME %K = %@", #keyPath(Note.tags), tag),
                                    showAddButton: true)
                self.items[tagsSection].append(item)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return
        }
    }
}

// MARK: UITableViewDataSource

extension MenuController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TagTableCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: Table cell configuration

extension MenuController {
    private func configure(cell: TagTableCell, indexPath: IndexPath) {
        let tag = items[indexPath.section][indexPath.row].tag
        let icon: Icon? = tag.icon
        cell.configure(text: tag.name, imageName: icon?.name, color: icon?.color)
    }
}

// MARK: UITableViewDelegate

extension MenuController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case tagsSection:
            let view = SectionView()
            view.label.text = NSLocalizedString("Tags", comment: "")
            return view
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case tagsSection:
            let view = SectionView()
            view.label.numberOfLines = 0
            view.label.font = UIFont.systemFont(ofSize: 12)
            view.label.text = "dev by Anatoliy Odinetskiy\n2020\nIcons by icons8.ru"
            return view
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case tagsSection:
            return 60
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case tagsSection:
            return 100
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section][indexPath.row]
        let controller = NotesTableController()
        
        controller.locale = locale
        controller.coreDataStack = coreDataStack
        controller.notificationsManager = notificationsManager
        
        controller.title = item.tag.name
        controller.showAddButton = item.showAddButton
        controller.tableDataSource.predicate = item.predicate
        
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true, completion: nil)
    }
}
