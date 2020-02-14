//
//  TagsTableController.swift
//  todo
//
//  Created by Анатолий on 12/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
import Panels
import UIKit

class TagsTableController: CustomViewController<TagsTableView> {
    lazy var addButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                             target: self,
                                             action: #selector(addTag))
    lazy var customEditButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                    target: self,
                                                    action: #selector(editButtonPressed))
    lazy var deleteButtonItem = UIBarButtonItem(image: UIImage(named: "trash"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(deleteButtonPressed))
    lazy var cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                target: self,
                                                action: #selector(cancelButtonPressed))
    let searchController = UISearchController(searchResultsController: nil)
    
    var coreDataStack: CoreDataStack!
    lazy var fetchedResultsController: NSFetchedResultsController<Tag> = {
        let sort = NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 10
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: coreDataStack.managedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
    }()
    
    var panelIsShowing: Bool = false
    lazy var panelManager = Panels(target: self)
    var panel: SelectedTagsTableView = UIStoryboard.instantiatePanel(identifier: "SelectedTagsPanel") as! SelectedTagsTableView

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupSearchController()
        
        customView.tableView.allowsMultipleSelectionDuringEditing = true
        customView.tableView.register(TagTableCell.self)
        customView.tableView.dataSource = self
        customView.tableView.delegate = self

        fetchedResultsController.delegate = self
        fetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        if !panelIsShowing {
            showPanel()
            panelIsShowing = true
        }
    }
}

// MARK: Layout

extension TagsTableController {
    func setupNavigationBar() {
        navigationItem.title = "Tags"
        navigationItem.leftBarButtonItem = customEditButtonItem
        navigationItem.rightBarButtonItem = addButtonItem
    }

    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func getDeleteAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let title = "Delete"
        let action = UIContextualAction(style: .normal, title: title) { _, _, completionHandler in
            print("Hi!")
            completionHandler(true)
        }
        action.backgroundColor = .systemRed
        action.image = UIImage(named: "trash")
        return action
    }
    
    func getEditAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let title = "Edit"
        let action = UIContextualAction(style: .normal, title: title) { _, _, completionHandler in
            print("Hi!")
            completionHandler(true)
        }
        action.backgroundColor = .systemGreen
        action.image = UIImage(named: "edit")
        return action
    }
    /*
    func getDeleteAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let title = "Delete"
        let deleteAction = UIContextualAction(style: .normal, title: title) { _, _, completionHandler in
            let alert = self.getDeleteAlertController(cellForRowAt: indexPath)
            self.present(alert, animated: true)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(named: "trash")
        return deleteAction
    }

    func getDeleteAlertController(cellForRowAt indexPath: IndexPath) -> UIAlertController {
        let tag = fetchedResultsController.object(at: indexPath)
        var message = ""
        if let name = tag.name, !name.isEmpty {
            message = "Удалить \(name)?"
        } else {
            message = "Удалить заметку?"
        }

        let title = "Удаление"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelTitle = "Отмена"
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        let deleteTitle = "Удалить"
        let deleteAction = UIAlertAction(title: deleteTitle, style: .destructive) { _ in
            self.coreDataStack.managedContext.delete(tag)
            self.coreDataStack.saveContext()
        }
        alert.addAction(deleteAction)

        return alert
    }
    */
}

// MARK: Helpers

extension TagsTableController {
    func fetch() {
        print("FETCH")
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    func exitFromEditMode() {
        customView.tableView.setEditing(false, animated: true)
        navigationItem.leftBarButtonItem = customEditButtonItem
        navigationItem.rightBarButtonItem = addButtonItem
    }
    
    func showPanel() {
        var panelConfiguration = PanelConfiguration(size: .thirdQuarter, margin: 0, visibleArea: 50)
        panelConfiguration.animateEntry = true
        panelManager.show(panel: self.panel, config: panelConfiguration)
    }
}

// MARK: Actions

extension TagsTableController {
    @objc func addTag() {
        /*
         let noteController = NoteViewController()
         noteController.coreDataStack = coreDataStack
         navigationController?.pushViewController(noteController, animated: true)
         */
    }

    @objc func editButtonPressed() {
        customView.tableView.setEditing(true, animated: true)
        deleteButtonItem.isEnabled = false
        navigationItem.leftBarButtonItem = deleteButtonItem
        navigationItem.rightBarButtonItem = cancelButtonItem
    }

    @objc func cancelButtonPressed() {
        exitFromEditMode()
    }

    @objc func deleteButtonPressed() {
        if let paths = customView.tableView.indexPathsForSelectedRows {
            var tags: [Tag] = []
            for indexPath in paths {
                let tag = fetchedResultsController.object(at: indexPath)
                tags.append(tag)
            }
            print("Удалено \(tags.count)")
            for tag in tags {
                coreDataStack.managedContext.delete(tag)
            }
            coreDataStack.saveContext()
        }
        exitFromEditMode()
    }
}

// MARK: UITableViewDataSource

extension TagsTableController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TagTableCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: Table cell configuration

extension TagsTableController {
    func configure(cell: UITableViewCell, indexPath: IndexPath) {
        let tag = fetchedResultsController.object(at: indexPath)
        cell.backgroundColor = .clear
        cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 10)
        cell.textLabel?.text = tag.name
        if let icon = tag.icon,
            let name = icon.name {
            cell.imageView?.image = UIImage(named: name)
            cell.imageView?.tintColor = UIColor(hex6: icon.color)
        } else {
            cell.imageView?.image = nil
        }

        setSelection(cell: cell, tag: tag)
    }

    func setSelection(cell: UITableViewCell, tag: Tag) {
        if panel.selectedTags.contains(tag) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
}

// MARK: UITableViewDelegate

extension TagsTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = getEditAction(cellForRowAt: indexPath)
        let deleteAction = getDeleteAction(cellForRowAt: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        return configuration
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else {
            deleteButtonItem.isEnabled = true
            return
        }
        let tag = fetchedResultsController.object(at: indexPath)
        if panel.selectedTags.contains(tag) {
            panel.deleteTag(tag)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            panel.addTag(tag)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        exitFromEditMode()
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

// MARK: UISearchResultsUpdating

extension TagsTableController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        if text == "", fetchedResultsController.fetchRequest.predicate == nil {
            return
        }

        let predicate = NSPredicate(format: "\(#keyPath(Tag.name)) CONTAINS[cd] %@", text)
        fetchedResultsController.fetchRequest.predicate = text == "" ? nil : predicate
        fetch()
        customView.tableView.reloadData()
    }
}

// MARK: NSFetchedResultsControllerDelegate

extension TagsTableController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        customView.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            customView.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            customView.tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = customView.tableView.cellForRow(at: indexPath!)
            configure(cell: cell!, indexPath: indexPath!)
        case .move:
            customView.tableView.deleteRows(at: [indexPath!], with: .automatic)
            customView.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        @unknown default:
            print("Unexpected NSFetchedResultsChangeType")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        customView.tableView.endUpdates()
    }
}
