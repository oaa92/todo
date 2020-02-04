//
//  NotesTableController.swift
//  todo
//
//  Created by Анатолий on 29/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
import UIKit

class NotesTableController: UITableViewController {
    let searchController = UISearchController(searchResultsController: nil)
    
    var coreDataStack: CoreDataStack!
    lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        let sort = NSSortDescriptor(key: #keyPath(Note.createdAt), ascending: false)
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 10
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex6: 0xF7ECE1)

        setupNavigationBar()
        setupSearchController()

        tableView.register(NoteCell.self)
        fetchedResultsController.delegate = self
        
        print("viewDidLoad")
        fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
}

// MARK: Layout

extension NotesTableController {
    func setupNavigationBar() {
        navigationItem.title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
    }

    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func getDeleteAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let deleteTitle = "Удалить"
        let deleteAction = UIContextualAction(style: .normal, title: deleteTitle) { (action, view, completionHandler) in
            let alert = self.getDeleteAlertController(cellForRowAt: indexPath)
            self.present(alert, animated: true)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        
        return deleteAction
    }
    
    func getDeleteAlertController(cellForRowAt indexPath: IndexPath) -> UIAlertController {
        let note = fetchedResultsController.object(at: indexPath)
        var message = ""
        if let title = note.title, !title.isEmpty {
            message = "Удалить \(title)?"
        } else {
            message = "Удалить заметку?"
        }
        
        let title = "Удаление"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelTitle = "Отмена"
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
            return
        }
        alert.addAction(cancelAction)
        
        let deleteTitle = "Удалить"
        let deleteAction = UIAlertAction(title: deleteTitle, style: .destructive) { (action) in
            self.coreDataStack.managedContext.delete(note)
            self.coreDataStack.saveContext()
        }
        alert.addAction(deleteAction)
        
        return alert
    }
}

// MARK: Helpers

extension NotesTableController {
    func fetch() {
        print("FETCH")
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}

// MARK: Actions

extension NotesTableController {
    @objc func addNote() {
        let noteController = NoteViewController()
        noteController.coreDataStack = coreDataStack
        navigationController?.pushViewController(noteController, animated: true)
    }
}

// MARK: UITableViewDelegate

extension NotesTableController{
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = getDeleteAction(cellForRowAt: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}

// MARK: UITableViewDataSource

extension NotesTableController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NoteCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: Table cell configuration

extension NotesTableController {
    func configure(cell: NoteCell, indexPath: IndexPath) {
        let note = fetchedResultsController.object(at: indexPath)

        // title
        if let title = note.title {
            cell.stack.insertArrangedSubview(cell.titleLabel, at: 0)
            cell.titleLabel.text = title
        }

        if let glayer = cell.noteView.layer as? CAGradientLayer {
            glayer.colors = [UIColor(hex6: 0xBFD6AD).cgColor, UIColor(hex6: 0xFFCAAF).cgColor]
        }

        cell.noteView.text = note.text
    }
}

// MARK: UISearchResultsUpdating

extension NotesTableController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        if text == "", fetchedResultsController.fetchRequest.predicate == nil {
            return
        }

        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "\(#keyPath(Note.title)) CONTAINS[cd] %@", text),
            NSPredicate(format: "\(#keyPath(Note.text)) CONTAINS[cd] %@", text),
        ])
        fetchedResultsController.fetchRequest.predicate = text == "" ? nil : predicate
        fetch()
        tableView.reloadData()
    }
}

// MARK: NSFetchedResultsControllerDelegate

extension NotesTableController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! NoteCell
            configure(cell: cell, indexPath: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        @unknown default:
            print("Unexpected NSFetchedResultsChangeType")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
