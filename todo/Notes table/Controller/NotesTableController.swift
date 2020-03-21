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
    var locale: Locale!
    var coreDataStack: CoreDataStack!
    var notificationsManager: NotificationsManager!

    var showAddButton = true
    private lazy var addButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                     target: self,
                                                     action: #selector(addNote))
    private lazy var customEditButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editButtonPressed))
    private lazy var deleteButtonItem = UIBarButtonItem(image: UIImage(named: "trash"),
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(deleteButtonPressed))
    private lazy var cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                        target: self,
                                                        action: #selector(cancelButtonPressed))
    private lazy var menuButtonItem = UIBarButtonItem(image: UIImage(named: "menu"),
                                                      style: .plain,
                                                      target: self,
                                                      action: #selector(menuButtonPressed))

    private let searchController = UISearchController(searchResultsController: nil)

    lazy var tableDataSource: NotesTableDataSource = {
        let dataSource = NotesTableDataSource()
        dataSource.locale = locale
        dataSource.coreDataStack = coreDataStack
        dataSource.predicate = NSPredicate(format: "%K = nil", #keyPath(Note.deletedAt))
        return dataSource
    }()

    private var audioPlayer: AVAudioPlayer?

    private let toastManager = ToastManager()

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let url = Bundle.main.url(forResource: "crumpled paper", withExtension: "wav")
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
        } catch {
            print(error.localizedDescription)
        }

        setupNavigationBar()
        setupSearchController()

        customView.tableView.register(NoteCell.self)
        customView.tableView.dataSource = tableDataSource
        customView.tableView.delegate = self

        tableDataSource.fetchedResultsController.delegate = self
        fetch()
    }
}

// MARK: Layout

extension NotesTableController {
    private func setupNavigationBar() {
        if title ?? "" == "" {
            title = NSLocalizedString("Notes", comment: "")
        }
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItems = [menuButtonItem, customEditButtonItem]
        if showAddButton {
            navigationItem.rightBarButtonItem = addButtonItem
        }
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "")
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

// MARK: Helpers

extension NotesTableController {
    private func fetch() {
        do {
            try tableDataSource.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    private func getDeleteAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let title = NSLocalizedString("Delete", comment: "")
        let action = UIContextualAction(style: .destructive, title: title) { _, _, completionHandler in
            let note = self.tableDataSource.fetchedResultsController.object(at: indexPath)
            let message = note.deletedAt == nil ? NSLocalizedString("Moved to trash", comment: "") : NSLocalizedString("Deleted", comment: "")
            self.deleteNote(note: note)
            self.coreDataStack.saveContext()
            self.showDeleteNotification(message: message)
            completionHandler(true)
        }
        action.backgroundColor = UIColor.Palette.Buttons.delete.get
        action.image = UIImage(named: "trash")
        return action
    }

    private func getRecoverAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let title = NSLocalizedString("Recover", comment: "")
        let action = UIContextualAction(style: .destructive, title: title) { _, _, completionHandler in
            let note = self.tableDataSource.fetchedResultsController.object(at: indexPath)
            note.deletedAt = nil
            self.coreDataStack.saveContext()
            completionHandler(true)
        }
        action.backgroundColor = UIColor.Palette.green.get
        action.image = UIImage(named: "recover")
        return action
    }

    private func showDeleteNotification(message: String) {
        toastManager.show(message: message, image: UIImage(named: "trash"), controller: self)
        audioPlayer?.play()
    }

    private func exitFromEditMode() {
        customView.tableView.setEditing(false, animated: true)
        navigationItem.setLeftBarButtonItems([menuButtonItem, customEditButtonItem], animated: true)
        
        var rightItems: [UIBarButtonItem] = []
        if showAddButton {
            rightItems.append(addButtonItem)
        }
        navigationItem.setRightBarButtonItems(rightItems, animated: true)
    }

    private func createNoteController(note: Note) -> NoteViewController {
        let noteController = NoteViewController()
        noteController.locale = locale
        noteController.coreDataStack = coreDataStack
        noteController.notificationsManager = notificationsManager
        noteController.note = note
        noteController.noteDelegate = self
        return noteController
    }

    private func deleteNote(note: Note) {
        if note.deletedAt == nil {
            let ids = note.moveToTrash(coreDataStack)
            coreDataStack.saveContext()
            notificationsManager.deregister(ids: ids)
        } else {
            note.delete(coreDataStack: coreDataStack)
        }
    }
}

// MARK: Actions

extension NotesTableController {
    @objc private func addNote() {
        let noteController = createNoteController(note: Note(context: coreDataStack.managedContext))
        navigationController?.pushViewController(noteController, animated: true)
    }

    @objc private func editButtonPressed() {
        customView.tableView.setEditing(true, animated: true)
        deleteButtonItem.isEnabled = false
        navigationItem.setLeftBarButtonItems([deleteButtonItem], animated: true)
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
            let deleteDates = notes.compactMap { $0.deletedAt }
            let message: String
            if deleteDates.count > 0 {
                message = NSLocalizedString("Deleted", comment: "")
            } else {
                message = NSLocalizedString("Moved to trash", comment: "")
            }
            notes.forEach {
                self.deleteNote(note: $0)
            }
            coreDataStack.saveContext()
            showDeleteNotification(message: message)
        }
        exitFromEditMode()
    }

    @objc private func menuButtonPressed() {
        let menuController = MenuController()
        menuController.locale = locale
        menuController.coreDataStack = coreDataStack
        menuController.notificationsManager = notificationsManager        
        let navigationController = UINavigationController(rootViewController: menuController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: UITableViewDelegate

extension NotesTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let note = tableDataSource.fetchedResultsController.object(at: indexPath)
        let deleteAction = getDeleteAction(cellForRowAt: indexPath)
        var actions: [UIContextualAction] = [deleteAction]
        if note.deletedAt != nil {
            let recoverAction = getRecoverAction(cellForRowAt: indexPath)
            actions.append(recoverAction)
        }
        let configuration = UISwipeActionsConfiguration(actions: actions)
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
            tableView.deselectRow(at: indexPath, animated: true)
            let note = tableDataSource.fetchedResultsController.object(at: indexPath)
            let noteController = createNoteController(note: note)
            navigationController?.pushViewController(noteController, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = false }
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        exitFromEditMode()
        navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = true }
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !searchController.isActive else {
            return
        }
        tableDataSource.removeProvidersForNotVisibleNotes()
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
        tableDataSource.removeProvidersForNotVisibleNotes()
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
            guard let newIndexPath = newIndexPath else {
                break
            }
            customView.tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {
                break
            }
            customView.tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else {
                break
            }
            let note = tableDataSource.fetchedResultsController.object(at: indexPath)
            if let uid = note.uid {
                tableDataSource.providers[uid] = nil
            }
            if let cell = customView.tableView.cellForRow(at: indexPath) as? NoteCell {
                tableDataSource.configure(cell: cell, indexPath: indexPath)
            }
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else {
                break
            }
            customView.tableView.deleteRows(at: [indexPath], with: .automatic)
            customView.tableView.insertRows(at: [newIndexPath], with: .automatic)
        @unknown default:
            print("Unexpected NSFetchedResultsChangeType")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        customView.tableView.endUpdates()
    }
}

// MARK: NoteProtocol

extension NotesTableController: NoteProtocol {
    func updateNote(note: Note) {
        guard let indexPath = tableDataSource.fetchedResultsController.indexPath(forObject: note) else {
            return
        }
        customView.tableView.beginUpdates()
        if let uid = note.uid {
            tableDataSource.providers[uid] = nil
        }
        if let cell = customView.tableView.cellForRow(at: indexPath) as? NoteCell {
            tableDataSource.configure(cell: cell, indexPath: indexPath)
        }
        customView.tableView.endUpdates()
    }
}
