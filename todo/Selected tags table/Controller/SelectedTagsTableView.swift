//
//  SelectedTagsTableView.swift
//  todo
//
//  Created by Анатолий on 13/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Panels

class SelectedTagsTableView: UIViewController, Panelable {
    @IBOutlet var headerHeight: NSLayoutConstraint!
    @IBOutlet var headerPanel: UIView!
    @IBOutlet var tableView: UITableView!
    private(set) var selectedTags: [Tag] = []
    var coreDataStack: CoreDataStack!
    weak var tagUnselectionDelegate: TagUnselectionProtocol?

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        tableView.register(TagTableCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.curveTopCorners()
    }
}

// MARK: Layout

extension SelectedTagsTableView {
    private func setupView() {
        view.backgroundColor = .clear
        headerPanel.backgroundColor = UIColor.Palette.orange_pale.get
        tableView.backgroundColor = UIColor.Palette.grayish_orange.get
        view.layoutIfNeeded()
    }
}

// MARK: Helpers

extension SelectedTagsTableView {
    func setTags(_ tags: [Tag]) {
        selectedTags = tags
    }

    private func getUnselectAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let title = "Unselect"
        let action = UIContextualAction(style: .destructive, title: title) { _, _, completionHandler in
            let index = indexPath.row
            let tag = self.selectedTags[index]
            self.deleteTag(tag)
            if let delegate = self.tagUnselectionDelegate {
                delegate.tagDidUnselect(tag: tag)
            }
            completionHandler(true)
        }
        action.backgroundColor = UIColor.Palette.Buttons.unselected.get
        return action
    }

    private func getEditAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let title = "Edit"
        let action = UIContextualAction(style: .normal, title: title) { _, _, completionHandler in
            let index = indexPath.row
            let tag = self.selectedTags[index]
            let tagController = TagViewController()
            tagController.coreDataStack = self.coreDataStack
            tagController.tag = tag
            self.navigationController?.pushViewController(tagController, animated: true)
            completionHandler(true)
        }
        action.backgroundColor = UIColor.Palette.Buttons.edit.get
        action.image = UIImage(named: "edit")
        return action
    }

    private func getDeleteAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let title = "Delete"
        let action = UIContextualAction(style: .destructive, title: title) { _, _, completionHandler in
            let index = indexPath.row
            let tag = self.selectedTags[index]
            self.selectedTags.remove(at: index)
            tag.delete(coreDataStack: self.coreDataStack)
            self.coreDataStack.saveContext()
            completionHandler(true)
        }
        action.backgroundColor = UIColor.Palette.Buttons.delete.get
        action.image = UIImage(named: "trash")
        return action
    }
}

// MARK: UITableViewDataSource

extension SelectedTagsTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTags.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TagTableCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: Table cell configuration

extension SelectedTagsTableView {
    private func configure(cell: TagTableCell, indexPath: IndexPath) {
        let index = indexPath.row
        let tag = selectedTags[index]
        let icon: Icon? = tag.icon
        cell.configure(text: tag.name, imageName: icon?.name, color: icon?.color)
    }
}

// MARK: UITableViewDelegate

extension SelectedTagsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let unselectAction = getUnselectAction(cellForRowAt: indexPath)
        let editAction = getEditAction(cellForRowAt: indexPath)
        let deleteAction = getDeleteAction(cellForRowAt: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: [unselectAction, editAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

// MARK: Table content changed

extension SelectedTagsTableView {
    enum TagChangeType {
        case insert
        case delete
        case update
    }

    func addTag(_ tag: Tag) {
        selectedTags.append(tag)
        tableViewDidChangedContent(at: IndexPath(row: selectedTags.count - 1, section: 0), type: .insert)
    }

    func deleteTag(_ tag: Tag) {
        guard let index = selectedTags.firstIndex(of: tag) else {
            return
        }
        selectedTags.remove(at: index)
        tableViewDidChangedContent(at: IndexPath(row: index, section: 0), type: .delete)
    }

    func updateTag(_ tag: Tag) {
        guard let index = selectedTags.firstIndex(of: tag) else {
            return
        }
        tableViewDidChangedContent(at: IndexPath(row: index, section: 0), type: .update)
    }

    private func tableViewDidChangedContent(at indexPath: IndexPath, type: TagChangeType) {
        tableView.beginUpdates()
        switch type {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath) as? TagTableCell {
                configure(cell: cell, indexPath: indexPath)
            }
        }
        tableView.endUpdates()
    }
}
