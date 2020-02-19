//
//  NotesTableController.swift
//  todo
//
//  Created by Анатолий on 29/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import AVFoundation
import CoreData
import UIKit

class NotesTableController: CustomViewController<NotesTableView>, AVAudioPlayerDelegate {
    lazy var addButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                             target: self,
                                             action: #selector(addNote))
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

    var tableDataSource = NotesTableDataSource()

    var audioPlayer: AVAudioPlayer?

    let toastManager = ToastManager()

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let url = Bundle.main.url(forResource: "crumpled paper", withExtension: "wav")
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
        } catch {
            print(error)
        }

        setupNavigationBar()
        setupSearchController()

        customView.tableView.register(NoteCell.self)
        customView.tableView.dataSource = tableDataSource
        customView.tableView.delegate = self

        tableDataSource.coreDataStack = coreDataStack
        tableDataSource.fetchedResultsController.delegate = self
        fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
}

// MARK: Layout

extension NotesTableController {
    private func setupNavigationBar() {
        navigationItem.title = "Notes"
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.setLeftBarButton(customEditButtonItem, animated: false)
        navigationItem.setRightBarButton(addButtonItem, animated: false)
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

// MARK: Helpers

extension NotesTableController {
    private func fetch() {
        print("FETCH")
        do {
            try tableDataSource.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    private func getDeleteAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let title = "Delete"
        let action = UIContextualAction(style: .destructive, title: title) { _, _, completionHandler in
            let note = self.tableDataSource.fetchedResultsController.object(at: indexPath)
            note.detetedAt = Date()
            self.coreDataStack.saveContext()
            self.showDeleteNotification()
            completionHandler(true)
        }
        action.backgroundColor = UIColor(hex6: 0xFB7670)
        action.image = UIImage(named: "trash")
        return action
    }

    private func getFavouritesAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let title = "Favourites"
        let action = UIContextualAction(style: .normal, title: title) { _, _, completionHandler in
            // let note = self.tableDataSource.fetchedResultsController.object(at: indexPath)
            // self.coreDataStack.saveContext()
            completionHandler(true)
        }
        action.backgroundColor = UIColor(hex6: 0x7D3BB8)
        action.image = UIImage(named: "favourite")
        return action
    }

    private func showDeleteNotification() {
        toastManager.show(message: "Перенесено в корзину", image: UIImage(named: "trash"), controller: self)
        audioPlayer?.play()
    }

    private func exitFromEditMode() {
        customView.tableView.setEditing(false, animated: true)
        navigationItem.setLeftBarButton(customEditButtonItem, animated: true)
        navigationItem.setRightBarButton(addButtonItem, animated: true)
    }
}

// MARK: Actions

extension NotesTableController {
    @objc private func addNote() {
        let noteController = NoteViewController()
        noteController.coreDataStack = coreDataStack
        navigationController?.pushViewController(noteController, animated: true)
    }

    @objc private func editButtonPressed() {
        customView.tableView.setEditing(true, animated: true)
        deleteButtonItem.isEnabled = false
        navigationItem.setLeftBarButton(deleteButtonItem, animated: true)
        navigationItem.setRightBarButton(cancelButtonItem, animated: true)
    }

    @objc private func cancelButtonPressed() {
        exitFromEditMode()
    }

    @objc private func deleteButtonPressed() {
        guard customView.tableView.isEditing else {
            return
        }

        if let paths = customView.tableView.indexPathsForSelectedRows {
            let notes = paths.map { tableDataSource.fetchedResultsController.object(at: $0) }
            notes.forEach { $0.detetedAt = Date() }
            coreDataStack.saveContext()
            showDeleteNotification()
        }
        exitFromEditMode()
    }
}

// MARK: Random notes generator

extension NotesTableController {
    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print(customView.tableView.isEditing)
            for _ in 0..<1 {
                let generator = RandomNoteGenerator()
                _ = generator.generate(context: coreDataStack.managedContext)
                coreDataStack.saveContext()
            }
        }
    }
}

// MARK: UITableViewDelegate

extension NotesTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favouritesAction = getFavouritesAction(cellForRowAt: indexPath)
        let deleteAction = getDeleteAction(cellForRowAt: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: [favouritesAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            deleteButtonItem.isEnabled = true
        } else {
            let note = tableDataSource.fetchedResultsController.object(at: indexPath)
            let noteController = NoteViewController()
            noteController.coreDataStack = coreDataStack
            noteController.note = note
            navigationController?.pushViewController(noteController, animated: true)
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

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !searchController.isActive else {
            return
        }

        let note = tableDataSource.fetchedResultsController.object(at: indexPath)
        tableDataSource.providers[note.uid!] = nil
    }
}

// MARK: UISearchResultsUpdating

extension NotesTableController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        if text == "",
            tableDataSource.fetchedResultsController.fetchRequest.predicate == tableDataSource.predicate {
            return
        }

        let predicate: NSPredicate
        if text == "" {
            predicate = tableDataSource.predicate
        } else {
            let filterP = NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Note.title), text),
                NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Note.text), text)
            ])
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [tableDataSource.predicate, filterP])
        }
        tableDataSource.fetchedResultsController.fetchRequest.predicate = predicate
        fetch()
        customView.tableView.reloadData()

        let uids: Set<UUID> = Set(tableDataSource.fetchedResultsController.fetchedObjects?.compactMap { $0.uid } ?? [])
        for key in tableDataSource.providers.keys {
            if !uids.contains(key) {
                tableDataSource.providers.removeValue(forKey: key)
            }
        }
    }
}

// MARK: NSFetchedResultsControllerDelegate

extension NotesTableController: NSFetchedResultsControllerDelegate {
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
            let note = tableDataSource.fetchedResultsController.object(at: indexPath!)
            tableDataSource.providers[note.uid!] = nil

            let cell = customView.tableView.cellForRow(at: indexPath!) as! NoteCell
            tableDataSource.configure(cell: cell, indexPath: indexPath!)
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
