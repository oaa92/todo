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
        let tag = Tag.createWithParams(name: NSLocalizedString("Notes", comment: ""))
        let item = MenuItem(tag: tag,
                            predicate: NSPredicate(format: "%K = nil", #keyPath(Note.deletedAt)),
                            showAddButton: true)
        items[headersSection].append(item)
    }

    private func addNotifications() {
        let icon = Icon.createWithParams(name: "notification",
                                         color: UIColor.Palette.blue_soft.get.rgb!)
        let tag = Tag.createWithParams(name: NSLocalizedString("Notifications", comment: ""),
                                       icon: icon)
        let item = MenuItem(tag: tag,
                            predicate: NSPredicate(format: "%K.@count > 0", #keyPath(Note.notifications)),
                            showAddButton: true)
        items[headersSection].append(item)
    }

    private func addTrash() {
        let icon = Icon.createWithParams(name: "trash",
                                         color: UIColor.Palette.Buttons.delete.get.rgb!)
        let tag = Tag.createWithParams(name: NSLocalizedString("Trash", comment: ""), icon: icon)
        let item = MenuItem(tag: tag,
                            predicate: NSPredicate(format: "%K != nil", #keyPath(Note.deletedAt)),
                            showAddButton: false)
        items[headersSection].append(item)
    }

    private func fetchTags() {
        do {
            let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
            let predicate = NSPredicate(format: "SUBQUERY(%K, $n, $n.%K = nil).@count > 0",
                                        #keyPath(Tag.notes),
                                        #keyPath(Note.deletedAt))
            fetchRequest.predicate = predicate
            let tags = try coreDataStack.managedContext.fetch(fetchRequest)
            for tag in tags {
                let item = MenuItem(tag: tag,
                                    predicate: predicateForTag(tag: tag),
                                    showAddButton: true)
                items[tagsSection].append(item)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return
        }
    }

    private func predicateForTag(tag: Tag) -> NSPredicate {
        return NSPredicate(format: "%K = nil && SOME %K = %@", #keyPath(Note.deletedAt), #keyPath(Note.tags), tag)
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
            view.label.text = NSLocalizedString("By tags", comment: "")
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
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == tagsSection else {
            return nil
        }

        let tag = items[indexPath.section][indexPath.row].tag
        let actionManager = TagActionCreator()
        actionManager.coreDataStack = coreDataStack

        let editAction = actionManager.getEditAction(tag: tag,
                                                     navigationController: navigationController,
                                                     tagEditDelegate: self)

        let deleteAction = actionManager.getDeleteAction(tag: tag) {
            self.items[indexPath.section].remove(at: indexPath.row)
            self.customView.tableView.beginUpdates()
            self.customView.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.customView.tableView.endUpdates()
        }

        let configuration = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

// MARK: TagEditProtocol

extension MenuController: TagEditProtocol {
    func tagDidChange(tag: Tag) {
        if let index = items[tagsSection].firstIndex(where: { $0.tag == tag }) {
            customView.tableView.beginUpdates()
            let indexPath = IndexPath(row: index, section: tagsSection)
            if let cell = customView.tableView.cellForRow(at: indexPath) as? TagTableCell {
                configure(cell: cell, indexPath: indexPath)
            }
            customView.tableView.endUpdates()
        }
    }
}
