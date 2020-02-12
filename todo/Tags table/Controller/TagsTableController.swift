//
//  TagsTableController.swift
//  todo
//
//  Created by Анатолий on 12/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
import UIKit

class TagsTableController: CustomViewController<TagsTableView> {
    
    class TagsTableProvider {
        
    }    
    
    
    enum DisplayMode {
        case all
        case selected
    }
    
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

    var isSelectable: Bool = true
    var mode: DisplayMode = .all
    var selectedTags: [Tag] = []
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupSearchController()
        setupButtonAction()
        
        customView.tableView.allowsMultipleSelectionDuringEditing = true
        customView.tableView.register(TagTableCell.self)
        customView.tableView.dataSource = self
        customView.tableView.delegate = self

        fetchedResultsController.delegate = self
        fetch()
    }
}

// MARK: Layout

extension TagsTableController {
    func setupButtonAction() {
        guard isSelectable else {
            return
        }
        customView.button.addTarget(self, action: #selector(changeMode), for: .touchUpInside)
    }
    
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
}

// MARK: Helpers

extension TagsTableController {
    func getTag(at indexPath: IndexPath) -> Tag {
        guard <#condition#> else {
            <#statements#>
        }
        
        switch mode {
        case .all:
            let tag = fetchedResultsController.object(at: indexPath)
            return tag
        case .selected:
            let tag = selectedTags[indexPath.row]
            return tag
        }
    }
    
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
        updateButton()
    }
    
    func updateButton() {
        guard isSelectable,
            !customView.tableView.isEditing else {
            customView.button.isHidden = true
            return
        }
        let state: (title: String, isHidden: Bool)
        switch mode {
        case .all:
            state = (
                title: "Показать выбранные" + " (\(selectedTags.count))",
                isHidden: selectedTags.count == 0
            )
        case .selected:
            state = (
                title: "Показать все",
                isHidden: false
            )
        }
        customView.button.setTitle(state.title, for: .normal)
        customView.button.isHidden = state.isHidden
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
        updateButton()
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
    
    @objc func changeMode() {
        if mode == .all {
            mode = .selected
        } else {
            mode = .all
        }
        customView.tableView.reloadData()
        updateButton()
        searchController.searchBar.text = ""
    }
}

// MARK: UITableViewDataSource

extension TagsTableController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch mode {
        case .all:
            return fetchedResultsController.sections?.count ?? 0
        case .selected:
            return selectedTags.count > 0 ? 1 : 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .all:
            guard let sectionInfo = fetchedResultsController.sections?[section] else {
                return 0
            }
            return sectionInfo.numberOfObjects
        case .selected:
            return selectedTags.count
        }
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
        let tag = getTag(at: indexPath)
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
        if selectedTags.contains(tag) {
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
        let deleteAction = getDeleteAction(cellForRowAt: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isSelectable else {
            let tag = fetchedResultsController.object(at: indexPath)
            print("open tag")
            return
        }
        
        
        
        if tableView.isEditing {
            deleteButtonItem.isEnabled = true
        } else {
            let tag = fetchedResultsController.object(at: indexPath)
            if selectedTags.contains(tag) {
                deleteFromSelected(tag)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                selectedTags.append(tag)
                tableView.reloadRows(at: [indexPath], with: .automatic)
                updateButton()
                customView.button.isHidden = false
            }
        }
    }
    
    func deleteFromSelected(_ tag: Tag) {
        guard let index = selectedTags.firstIndex(of: tag) else {
            return
        }
        selectedTags.remove(at: index)
        if selectedTags.count == 0 {
            customView.button.isHidden = true
        } else {
            updateButton()
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
