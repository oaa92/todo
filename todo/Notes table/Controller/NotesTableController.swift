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

class NotesTableController: UITableViewController, AVAudioPlayerDelegate {
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
    var audioPlayer: AVAudioPlayer?
    let searchController = UISearchController(searchResultsController: nil)
    var coreDataStack: CoreDataStack!
    lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        let sort = NSSortDescriptor(key: #keyPath(Note.createdAt), ascending: false)
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 10
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: coreDataStack.managedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
    }()

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let url = Bundle.main.url(forResource: "crumpled paper", withExtension: "wav")
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
        } catch {
            print(error)
        }

        view.backgroundColor = UIColor.Palette.grayish_orange.get
        setupNavigationBar()
        setupSearchController()

        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.register(NoteCell.self)

        fetchedResultsController.delegate = self
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
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        let deleteTitle = "Удалить"
        let deleteAction = UIAlertAction(title: deleteTitle, style: .destructive) { _ in
            self.coreDataStack.managedContext.delete(note)
            self.coreDataStack.saveContext()
            self.audioPlayer?.play()
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

    @objc func editButtonPressed() {
        tableView.setEditing(true, animated: true)
        deleteButtonItem.isEnabled = false
        navigationItem.leftBarButtonItem = deleteButtonItem
        navigationItem.rightBarButtonItem = cancelButtonItem
    }

    @objc func cancelButtonPressed() {
        exitFromEditMode()
    }

    @objc func deleteButtonPressed() {
        if let paths = tableView.indexPathsForSelectedRows {
            var notes: [Note] = []
            for indexPath in paths {
                let note = fetchedResultsController.object(at: indexPath)
                notes.append(note)
            }
            print("Удалено \(notes.count)")
            for note in notes {
                coreDataStack.managedContext.delete(note)
            }
            coreDataStack.saveContext()
            audioPlayer?.play()
        }
        exitFromEditMode()
    }

    func exitFromEditMode() {
        tableView.setEditing(false, animated: true)
        navigationItem.leftBarButtonItem = customEditButtonItem
        navigationItem.rightBarButtonItem = addButtonItem
    }
}

extension NotesTableController {
    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print(tableView.isEditing)
            for _ in 0..<1 {
                let generator = RandomNoteGenerator()
                _ = generator.generate(context: coreDataStack.managedContext)
                coreDataStack.saveContext()
            }
        }
    }
}

// MARK: UITableViewDelegate

extension NotesTableController {
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = getDeleteAction(cellForRowAt: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            deleteButtonItem.isEnabled = true
        } else {
            //tableView.deselectRow(at: indexPath, animated: false)
            let note = fetchedResultsController.object(at: indexPath)
            let noteController = NoteViewController()
            noteController.coreDataStack = coreDataStack
            noteController.note = note
            navigationController?.pushViewController(noteController, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        exitFromEditMode()
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
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
            cell.titleLabel.isHidden = false
            cell.titleLabel.text = title
        }

        // text
        cell.noteView.text = note.text
        if let layer = cell.noteView.layer as? CAGradientLayer,
            let startPointStr = note.background?.startPoint,
            let endPointStr = note.background?.endPoint,
            let cgColors = note.background?.cgColors,
            cgColors.count > 1 {
            let startPoint = NSCoder.cgPoint(for: startPointStr)
            let endPoint = NSCoder.cgPoint(for: endPointStr)
            layer.startPoint = startPoint
            layer.endPoint = endPoint
            layer.colors = cgColors
        }
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
